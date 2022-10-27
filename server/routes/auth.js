const express = require('express');
const User = require('../models/user_model');

const jwt = require('jsonwebtoken')

const auth = require('../middleware/auth')


const authRouter = express.Router();

authRouter.post("/api/signup", async (req, res) => {
    try {
        const { name, email, profilePic } = req.body;
        let user = await User.findOne({ email });
        if (!user) {
            user = new User({
                email,
                profilePic,
                name,
            });
            user = await user.save();
        }

        const token = jwt.sign({ id: user._id }, "passwordKey")

        res.json({ user, token });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});


authRouter.get("/", auth, async (req, res) => {
    try {
        let user = await User.findById(req.user);
        res.json({ user, token: req.token })
    } catch (error) {
        console.log(error);
    }
})


module.exports = authRouter