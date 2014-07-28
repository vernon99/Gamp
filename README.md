[![Stories in Ready](https://badge.waffle.io/vernon99/Gamp.png?label=ready&title=Ready)](https://waffle.io/vernon99/Gamp)
Intro
====

Game analytics mobile panel
Written on Swift for Xcode beta 4

![Screenshot1](https://dl.dropboxusercontent.com/u/33878896/gamp01.png)
![Screenshot2](https://dl.dropboxusercontent.com/u/33878896/gamp02.png)

Note that grey line here is retention prediction. If there's no historical data, it's used instead, such as on the 2nd screenshot

How it works
====

Normally analytic platforms return you n-day retention and ARPDAU. But the most interesting metric is LTV and user lifetime as it's component. Lifetime could be calculated as a sum of all n-day retention values from day 1 to infinity. For the ease of use we could normally take 180-day span. This will basically give us the average player lifetime in days. Which we can then multiply with ARPDAU. That's not totally correct as ARPDAU could change with the player lifetime, but there's no way to extract n-day ARPDAU (as with n-day retention) from GA or any other platform known to me.

But what if we don't have historical data for n-day retention? Say, a new build was released few days ago and we don't have 14-day retention yet. To help solve this, extrapolation model could be applied. I used [Ordinary Least Squares](http://en.wikipedia.org/wiki/Ordinary_least_squares) regression model that gives pretty good results for late-stage retention.

Another question is what should we do with day zero, when all 100% of users were active, but some of them just opened and closed the app to never come back. It is safe to assume that users who came back at day 1 had same activity rate as zero day users. So we can just count 1st day retention twice during lifetime calculations.

Dependencies
====

* https://github.com/lingoer/SwiftyJSON by lingoer - safe JSON parsing
* https://github.com/kevinzhow/PNChart-Swift by kevinzhow - charts drawing
* https://github.com/yourkarma/JWT by yourkarma - Json Web Tokens lib
* https://github.com/ekscrypto/Base64 by ekscrypto - missing files for JWT

Contributing
====

1. Fork it. 
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

Thanks
====

Special thanks to Ivan Larionov for his advices on creating regression model for retention.