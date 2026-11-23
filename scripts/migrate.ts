import sql from 'mssql'

const env = (name: string): string => {
  const value = process.env[name]
  if (!value) throw new Error(`Missing ${name} in .env`)
  return value
}

const vars: Record<string, string> = {
  GAME_API_PASSWORD: env('GAME_API_PASSWORD'),
}

const substitute = (text: string) =>
  text.replace(/\$\((\w+)\)/g, (match, name: string) => {
    const value = vars[name]
    if (value === undefined) throw new Error(`Unknown variable ${match}`)
    return value.replaceAll("'", "''")
  })

const splitBatches = (text: string) =>
  text
    .split(/^\s*GO\s*;?\s*$/im)
    .map((batch) => batch.trim())
    .filter(Boolean)

const pool = await sql.connect({
  server: process.env.DB_HOST ?? 'localhost',
  port: Number(process.env.DB_PORT ?? 1433),
  user: 'sa',
  password: env('MSSQL_SA_PASSWORD'),
  database: 'master',
  options: { encrypt: true, trustServerCertificate: true },
  pool: { min: 1, max: 1 },
})

const files = (await Array.fromAsync(new Bun.Glob('db/*.sql').scan())).toSorted()

try {
  for (const file of files) {
    const batches = splitBatches(substitute(await Bun.file(file).text()))
    for (const [i, batch] of batches.entries()) {
      try {
        await pool.request().batch(batch)
      } catch (err) {
        console.error(`\n✗ ${file} (batch ${i + 1}/${batches.length})\n\n${batch}\n`)
        throw err
      }
    }
    console.log(`✓ ${file} (${batches.length} batches)`)
  }
} finally {
  await pool.close()
}
