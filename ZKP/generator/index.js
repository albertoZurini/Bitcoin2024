const express = require('express')
const { exec } = require('child_process');
const app = express()
const port = 3010

app.get('/api', (req, res) => {
    exec('python main.py 100 250 -10 0 10', (err, stdout, stderr) => {
        if (err) {
          // node couldn't execute the command
          return;
        }
      
        // the *entire* stdout and stderr (buffered)
        console.log(`stdout: ${stdout}`);
        console.log(`stderr: ${stderr}`);
      });
      
    res.send('Hello World!')
  })
  
app.use(express.static('public'))

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`)
})
