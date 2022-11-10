
const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');
const cors = require('cors');
const documentRouter = require('./routes/document');

const http = require('http')

const app = express()
var server = http.createServer(app)

var io = require('socket.io')(server);



const PORT = process.env.PORT | 4001

const Document = require('./models/document')



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

io.on('connection', (socket) => {
    console.log('Connected' + socket.id);
    socket.on('join', (documentId) => {
        socket.join(documentId)
    })

    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data)
    })

    socket.on('save', (data) => {
        saveData(data);
    })
})
const saveData = async (data) => {
    if (data.delta == null) return
    let document = await Document.findById(data.room);
    if (data.delta == null) {
        return
    }
    document.content = data.delta;
    document = await document.save();
}


server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
})