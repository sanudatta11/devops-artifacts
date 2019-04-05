var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
let validator = require('validator');
let async = require('async');
let jwt = require('jsonwebtoken');
let SHA256 = require('sha256-es');
let crypto = require('crypto');

let Recruiter = require('../models/recruiterSchema');
let Applicant = require('../models/applicantSchema');
let Question = require('../models/questionSchema');

let BaseURL = "https://ergasia-216815.firebaseapp.com/";
var Linkedin = require('node-linkedin')('814yacdk68651y', 'XLxay5VcmZYWaYAG', BaseURL + 'oauth/linkedin/callback');
var scope = ['r_basicprofile', 'r_emailaddress'];
router.createUserRecruiter = function (req, res, next) {
    try {
        let firstName = req.body.firstName.toLowerCase();
        let lastName = req.body.lastName.toLowerCase();
        let email = req.body.email.toLowerCase();
        let password = req.body.password.toLowerCase();
        let companyId = req.body.companyId;
        let imgUrl = req.body.imgUrl;
        async.waterfall([
            function (callback) {
                console.log('Data validation and checking');
                if (!(companyId && firstName && lastName && email && password)) {
                    res.status(400).json({
                        info: "Required data attributes not present!"
                    });
                } else {
                    if (companyId && !mongoose.Types.ObjectId.isValid(companyId)) {
                        res.status(400).json({
                            info: "Invalid companyId"
                        });
                    } else {
                        //Validation Check
                        let valid = true;
                        valid = valid && validator.isAlpha(firstName);
                        valid = valid && validator.isAlpha(lastName);
                        valid = valid && validator.isEmail(email);
                        valid = valid && !validator.isEmpty(password);

                        if (!valid)
                            res.status(401).json({
                                info: "Validion of data failed!"
                            });
                        else {
                            callback(null)
                        }
                    }
                }
            },
            function (callback) {
                let hash = crypto.createHash('sha256').update(password).digest('base64');
                Recruiter.findOne({
                    email :  email
                },function(err,data){
                    if(err)
                        res.status(500).json({
                            info : "Problem in searching previous same Recruiter",
                            error:err
                        });
                    else if(data)
                    {
                        res.status(300).json({
                            info : "Email exists"
                        })
                    }
                    else{
                        let userObj = new Recruiter({
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            password: hash,
                            companyId: companyId
                        });

                        if (imgUrl)
                            userObj.imgUrl = imgUrl;

                        userObj.save(function (err, data) {
                            if (err)
                                callback(err);
                            else
                                callback(null, data);
                        });
                    }
                });
            }
        ], function (err, result) {
            if (err)
                res.status(500).json({
                    error: err
                });
            else
                res.status(200).json(result);
        });

    } catch (error) {
        console.log(error);
        res.status(500).json(err);
    }
};

router.loginRecruiter = (req,res,next) => {
    let email = req.body.email;
    let password = req.body.password;
    let hash = crypto.createHash('sha256').update(password).digest('base64');
    Recruiter.findOne({
        email: email,
    }, function (err, data) {
        if (err)
            res.status(500).json({
                error: err
            });
        else if (!data)
            res.status(404).json({
                info: "Data not found"
            });
        else {
            if (data.password != hash) {
                res.status(400).json({
                    info: "Password Incorrect",
                })
            } else {
                let jwtToken = jwt.sign({
                    userId: data._id,
                    companyId: data.companyId
                }, 'supersecret', {
                    expiresIn: 150000000
                });

                res.status(200).json({
                    info: "Recruiter Login successfull",
                    token: jwtToken,
                })
            }
        }
    });
};

router.loginApplicant = (req,res,next) => {
    let email = req.body.email;
    let password = req.body.password;

    let hash = crypto.createHash('sha256').update(password).digest('base64');
    console.log(password,hash);
    Applicant.findOne({
        email: email,
    }, function (err, data) {
        if (err)
            res.status(500).json({
                error: err
            });
        else if (!data)
            res.status(404).json({
                info: "Data not found"
            });
        else {
            if (data.password !== hash) {
                res.status(400).json({
                    required: data.password,
                    got : hash,
                    info: "Password Incorrect",
                })
            } else {
                let jwtToken = jwt.sign({
                    userId: data._id,
                    companyId: data.companyId
                }, 'supersecret', {
                    expiresIn: 150000000
                });

                res.status(200).json({
                    info: "Applicant Login successful",
                    token: jwtToken,
                    userId: data._id,
                })
            }
        }
    });
};

router.loginLinkedInApplicant = (req, res) => {
    try {
        Linkedin.auth.getAccessToken(res, req.query.code, req.query.state, function(err, results) {
            if ( err )
                res.status(500).json(err);
            /**
             * Results have something like:
             * {"expires_in":5184000,"access_token":". . . ."}
             */
            let accessToken = results.access_token;
            var linkedin = Linkedin.init(accessToken);
            linkedin.people.me(function(err, data) {
                let email = data.emailAddress;
                let firstName = data.firstName;
                let lastName = data.lastName;

                Applicant.findOne({
                    email : email
                },function (err,userObj) {
                    if (err)
                        res.status(500).json({
                            error: err
                        });
                    else if (!userObj)
                    {
                        //Singup
                        let newUserObj = new Applicant({
                            email : email,
                            firstName : firstName,
                            password :  "O8Sbc+L7IBkk2dzOX7bW/Xz79YxJvozEZDnAXcY0sVE=",
                            lastName: lastName,
                            about : data.summary,
                            imgUrl : data.pictureUrls.values[0],
                            linkedIn : data.publicProfileUrl,
                            positions : data.positions
                        });

                        newUserObj.save(function (err,data) {
                            if(err)
                                res.status(500).json(err);
                            else if(!data)
                                res.status(404).json({
                                    info : "Save error signup"
                                })
                            else
                            {
                                let jwtToken = jwt.sign({
                                    userId: userObj._id
                                }, 'supersecret', {
                                    expiresIn: 150000000
                                });

                                res.status(200).json({
                                    info: "Applicant SignUp successfull",
                                    token: jwtToken,
                                    userId: data._id,
                                    email : email
                                })
                            }
                        });
                    }
                    else {
                        let jwtToken = jwt.sign({
                            userId: userObj._id,
                            companyId : userObj.companyId
                        }, 'supersecret', {
                            expiresIn: 150000000
                        });

                        res.status(200).json({
                            info: "Applicant Login successfull",
                            token: jwtToken,
                            userId: userObj._id,
                            email : email
                        })
                    }
                });
            });
        });
    }catch (e) {
        console.error(e);
        res.status(500).json(e);
    }
}
module.exports = router;