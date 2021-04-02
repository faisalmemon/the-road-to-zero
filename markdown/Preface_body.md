This book has come about because having written a book on iOS Crash Dump Analysis, I found that most of my audience were security-focussed engineers.

I share the same passion.  I have been studying various "Crack Me" challenges.  I thought I was doing the correct preparation for vulnerability analysis.

When I looked at successful exploits, mostly on Google Project Zero, I found there was a technique gap.  Not only do you need to apply standard techniques, you need to apply them on unfamiliar APIs, such as `IOSurface` and `XPC`.  So I naturally looked at Crack Me challenges using those APIs.  I wasn't able to find any.

What I am attempting to do is to document my journey in acquiring the skills to find Zero Day Vulnerabilities on iOS in the form of a book.  That is so that future engineers will have a book to take them along the same journey.

So the nature of this book is mostly a tutorial but with appropriate theory explanations or system knowledge explained along the way.

I take the view that when you are exploring new things, cost barriers are magnified because you are not sure at the time whether you will stick with it or enjoy it.  Paying a lot of money for golf clubs is a straightforward choice if you've already fallen in love with the game.  So I am going to work on the basis the reader has modest resources to hand (compared to the professionals in this area).  I assume you have an iDevice, a Mac, an Xcode developer account, and maybe software, free or licensed at modest cost.

There is one last element I intend to add to the mix.  The Hacker Mentality.  This is the attitude of mind where an innocent piece of information can be viewed through a hacker's lens.  That offers the foothold for us to commence experimentation and discovery that then later will result in new vulnerabilities.

If I am successful, I hope this book will become the handbook of vulnerability craftsmanship in the same way that Code Complete became the handbook of software craftsmanship.

One thing in particular that attracts me to iOS is that its one of the hardest platforms to circumvent.  It may turn out I don't reach the high bar needed to make progress on this platform.  But if it was going to be easy, what would be the point in trying?
