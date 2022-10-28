
const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const cors = require('cors');
const documentRouter = require('./routes/document');

const PORT = process.env.PORT | 4001


const app = express()
app.use(express.json())
app.use(cors())
app.use(authRouter)
app.use(documentRouter)



const DB = "mongodb+srv://test:test123@flutterfame.v340e8u.mongodb.net/?retryWrites=true&w=majority";


mongoose.connect(DB).then(() => {
    console.log("Connection SuccessFull!");
}).catch((err) => {
    console.log("There is error in Database Connection.");
    console.log(err);
})


app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
})