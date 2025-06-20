const jwt = require("jsonwebtoken");

const createAccessToken = async (user) => {
    const accessToken = await jwt.sign(
        {
            _id: user._id,
            email: user.email,
            username: user.username,
        },
        "1234",
        { expiresIn: "5d" }
    );
    return accessToken;
}

const decodeAccessToken = async (token) => {
    const decoded = await jwt.verify(token, "1234");
    return decoded;
}


module.exports = {
    createAccessToken,
    decodeAccessToken
}