const express = require('express')
const app = express()

/**
 * GET /hello
 * Returns "hello World!" 
 */
app.get('/hello', (_req, res) => {
  res.send('Hello World!')
})

/**
 * GET /wait
 * Waits for five seconds and then returns OK 
 */
app.get('/wait', (_req, res) => {
  // wait for five seconds then return ok
  setTimeout(() => {
    res.send('ok')
  }
  , 5000)
})

app.listen(3000, () => console.log('Listening on http://localhost:3000'))