
const mongoose = require('mongoose')

const documentSchema = mongoose.Schema({
    uid: {
        require: true,
        type: String
    },
    createdAt: {
        required: true,
        type: Number 
    },
    title: {
        required: true,
        type: String,
        trim: true,
    },
    content: {
        type: Array,
        default: [],
    }
})

const Document = mongoose.model('Document', documentSchema)


module.exports = Document;