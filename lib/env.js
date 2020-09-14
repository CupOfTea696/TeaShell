const process = require('process')

console.log(JSON.stringify(process.env, (k, v) => {
  try {
    return JSON.parse(v)
  } catch (err) {}

  return v
}))
