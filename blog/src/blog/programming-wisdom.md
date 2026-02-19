---
title: "Programming Wisdom"
pubDate: 2026-02-15
description: "Programming wisdom I shared on Quora in 2014"
author: "Jerome Terry"
image:
  url: "ChoosePaperOverPixels.png"
  alt: "Letter Board with the phrase: Choose Paper Over Pixels"
tags: ["programming", "software engineering"]
---

Here's an [Answer on Quora](https://qr.ae/pC6kTL) I wrote back in 2014. Much of this still resonates with me today.

---

## Question: What are the greatest programming tips and tricks you have learned on your own by years of coding?

## Answer:

I can't really claim I've learned the following lessons on my own. As the famous Newton quote goes
"standing on the shoulders of giants".

I've learned these lessons by hard work, and reading everything I could get my hands on over the course of the last
19 years - 5 years of university, 14 years programming.

These lessons have served me well. Hopefully they are helpful to you as they are to me.

---

**Get your mind right**. Getting good at programming takes practice and study, over many years. Read Peter Norvig’s
post [Teach Yourself Programming in Ten Years](https://norvig.com/21-days.html).

**Iterate**. Successive refinement is how we get to great code and great products. By iterating quickly, our goal is
to eliminate what does and doesn’t work as quickly and cheaply as possible. This is the core idea behind
[The Lean Startup](https://www.amazon.ca/Lean-Startup-Entrepreneurs-Continuous-Innovation/dp/0307887898).

**Simpler is usually better**. Watch Rich Hickey's talk
[Simple Made Easy](http://www.infoq.com/presentations/Simple-Made-Easy), and read
[Kent Beck's Xp Simplicity Rules](https://www.quora.com/profile/Kent-Beck). When I first started out programming, I
thought that my code was way too simple. As it turns out, simplicity is a good code quality! When you work on large
code bases, simplicity can get lost.

**Code is written primarily for coworkers not compilers**. The ultimate test if your code is simple enough is: can your
fellow programmers with similar backgrounds understand your code? If your co-workers have a hard time understanding
your code, investigate why. Maybe it’s your code that’s too complex. Maybe there weren’t enough tests. Maybe you used an
uncommon algorithm. The conversation about code is key.

**A problem you perceive is a problem you own**. I’m not sure where I heard this, but it has stuck with me through my
career. If you see an inefficiency, a bug, any sort of problem, it’s on you to take action to rectify it. Maybe adding
it to a bug database is sufficient. Maybe raise the issue with fellow developers. Or maybe make the fix yourself. This
ties in nicely with
[Don’t Live With Broken Windows](https://pragprog.com/the-pragmatic-programmer/extracts/software-entropy) from
[The Pragmatic Programmer](https://www.amazon.ca/Pragmatic-Programmer-Journeyman-Master/dp/020161622X).

**Don't be clever**. Don't try to write complicated code on purpose to show how smart you are. Write simple, clear,
reusable code. Think Simplicity, Clarity, Generality. Read
[The Practice of Programming](https://www.amazon.ca/Practice-Programming-Brian-W-Kernighan/dp/020161586X) by
Brian Kernighan and Rob Pike. Speaking of Brian Kernighan, also read the
[C Programming Language](https://www.amazon.ca/Programming-Language-2nd-Brian-Kernighan/dp/0131103628) by
Brian Kernighan and Dennis Ritchie.

**SRP (single responsibility principle)** and **DRY (don't repeat yourself)** principles go a long way towards clean
code. Read [Clean Code](https://www.amazon.ca/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882) by
Uncle Bob (Robert C. Martin).

You ain't gonna need it (**YAGNI**) applies most of the time. In general, just design for today's requirements, to
prevent over engineering. Having said that, sometimes it's necessary to design for future growth. There's a balance -
it's up to you to find it.

Code with obviously no bugs is immensely better than code with no obvious bugs.

Being able to reason about your code is paramount to high quality.

**Requirements are rarely cast in stone**. As an engineer/programmer, you have a responsibility to question things that
look unclear, in doubt and questionable. Sometimes when people don't like the questions, you really need to question
more intently, though possibly with careful discretion.
(Courtesy of [Bryan Kelly](https://www.quora.com/profile/Bryan-Kelly-18))

**Start with why**. Watch Simon Sinek's talk
[How great leaders inspire action](http://www.ted.com/talks/simon_sinek_how_great_leaders_inspire_action). This is my
all time favourite talk! Simon’s message “people don’t buy what you do, they buy why you do it” resonates with me. So
any project I work on, I want to know the bigger picture. I want to know the “why”.

When I get deep into a project, I can lose focus - in those moments I want to reflect on “why” I’m working on this
project, why this project is important to the world. That gives me clarity, and I can focus on the tasks that help move
me in the right direction. Without knowing “why”, I’m just flying blind, without purpose, which is wasteful. Knowing
“why" helps me prioritize, and gives me energy.

Related to the concept of why, often times you are working for someone else, and it’s their “why” that’s driving you.
Maybe you’re working for a CEO who has a vision for how the world can be a better place. No matter where you are in the
“chain of command”, you are a leader. Leadership is required at all levels for a company to be successful, even for
those who aren’t appointed leaders. I highly recommend reading
[Extreme Ownership: How US Navy SEALs Lead and Win](https://www.amazon.ca/Extreme-Ownership-U-S-Navy-SEALs/dp/1250183863).
This ties into [Start With Why](https://www.amazon.ca/Start-Why-Leaders-Inspire-Everyone/dp/1591846447) because if you
don’t understand “Why” or disagree with the leaders above you, it’s your responsibility to find out the leader's “Why”.
How can you lead others if you don’t understand why?

My second favourite talk of all time is [Inventing on Principle](https://vimeo.com/906418692) by Bret Victor. This talk
ties into [Start With Why](https://www.amazon.ca/Start-Why-Leaders-Inspire-Everyone/dp/1591846447) in my mind. Bret
talks about his guiding principle “Creators Need an Immediate Connection to What They Create”. This principle serves as
a guide to everything Bret does. This is a 3 part talk, and part 3 is perhaps the most important. It’s a single
question **“What is your guiding principle?“** To me, this ties into Simon Sinek’s talk “Start With Why”, since Simon’s
“Why” is very similar to Bret’s “Guiding Principle”.

I believe that one of the reasons we are put here on this earth is to discover our why. And to do that, I think we need
to know ourselves. To know our guiding principle. It’s very deep stuff.

**Clients don't really know what they want**, and that includes your manager. It's your job to elicit their true needs.

Despite what process you follow, **some amount of up front design is required** - how much should be proportional to
complexity. Read
[Domain Driven Design](https://www.amazon.ca/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215) by
Eric Evans.

Design patterns aren't used as much as you'd think. Recognizing common patterns is important.
**Don't treat patterns as a hammer looking for a nail**. Read
[Refactoring to Patterns](https://www.amazon.ca/Refactoring-Patterns-Joshua-Kerievsky/dp/0321213351) by
Joshua Kerievsky. Read Steven Grimm's answer to
[What are the most important design patterns that software engineers should know to work at Google, Amazon and Facebook?](http://www.quora.com/What-are-the-most-important-design-patterns-that-software-engineers-should-know-to-work-at-Google-Amazon-and-Facebook/answer/Steven-Grimm?srid=toWU&share=1)

**SOLID principles** (Single Responsibility Principle, Open/Closed Principle, Liskov Substitution Principle,
Interface Segregation Principle, Dependency Inversion Principle) are far more important than design patterns.
Read Uncle Bob's article [Principles Of OOD](http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod).

**Beware of dogma**. There's usually more than one way of doing things. The term "best practice" is overused. There are
some good practices in software development, but beware someone telling you that something is the "best" way of doing
something.

**No one has it all figured out**. Some know more than others. Always try to be the worst member in the band. Read
[The Passionate Programmer](https://www.amazon.ca/Passionate-Programmer-Creating-Remarkable-Development/dp/1934356344)
by Chad Fowler.

Watch Barbara Liskov's talk
[The Power of Abstraction](http://www.infoq.com/presentations/programming-abstraction-liskov). Many times I’ve seen
developers create meaningless abstractions.

The worst [abstraction](<https://en.wikipedia.org/wiki/Abstraction_(software_engineering)>) I’ve ever seen was a Java
class called BeanFacade. This class name was derived by jamming together the concept of a
[Java Bean](https://en.wikipedia.org/wiki/JavaBeans) with the
[Facade pattern](https://en.wikipedia.org/wiki/Facade_pattern). In Java, this is a common thing to do - concatenate
names together to form new names. But the resulting abstraction is meaningless. It might as well have been named X, or
FooBar. Be careful of what abstractions you let into your code bases. If you are struggling with naming things,
perhaps you don’t have the right abstraction.

In my mind, Eric Evans' book
[Domain Driven Design](https://www.amazon.ca/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)
is largely about choosing appropriate abstractions, and evolving them properly over time.

**There's no such thing as perfect**. You can always be better. "The perfect is the enemy of the good" - Voltaire.

If you don't **design** for scalability, your code won't scale. If you don't design for security, your code won't be
secure. Same applies for all -ilities.

**You are not your code**. Criticism of your code isn't a criticism of you.

**Remember, it's a team sport**. Great products are built by teams. Read the book
[5 Dysfunctions of a Team](https://www.amazon.ca/Five-Dysfunctions-Team-Leadership-Fable/dp/0787960756)
by Patrick Lencioni, or watch his [talk](https://www.youtube.com/watch?v=75bO_XWk7fw) about the book. It's a really
great book on how great teams operate.

**Don't go dark**. Share your unfinished work with others willingly. Read
[Dynamics of Software Development](https://www.amazon.ca/Dynamics-Software-Development-Michele-McCarthy/dp/0735623198)
by Jim McCarthy

**Test your work**. Try writing tests before code. Try TDD. Try BDD. Read
[Working Effectively with Legacy Code](https://www.amazon.ca/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052)
by Michael Feathers.

Learn multiple paradigms. **OOP**, **Functional**, etc. Your OO code will improve after studying functional languages
such as **Haskell** and **Lisp**.

Watch OOPSLA 97 Keynote by Alan Kay,
[The Computer Revolution Hasn't Happened Yet](https://www.youtube.com/watch?v=oKg1hTOQXoY).

**Never stop learning**. Read as many books as you can, but not only technical books. Read
[Zen And The Art of Motorcycle Maintenance](https://www.amazon.ca/Zen-Art-Motorcycle-Maintenance-Inquiry/dp/0061673730)
by Robert M. Pirsig.

Read [The Pragmatic Programmer](https://www.amazon.ca/Pragmatic-Programmer-journey-mastery-Anniversary/dp/0135957052)
by Andy Hunt and Dave Thomas.

Read [Code Complete 2](https://www.amazon.ca/Code-Complete-2nd-Steve-McConnell/dp/0735619670) by Steve McConnell

Read [SICP](https://www.amazon.ca/Structure-Interpretation-Computer-Programs-Abelson/dp/0262510871)
(Structure and Interpretation of Computer Programs) by Harold Abelson, Gerald Jay Sussman, and Julie Sussman. Don't
just read it cover to cover. Follow along with a Scheme environment (e.g. Racket) and actually write some code.

Don't ask permission to refactor, test, document etc. It's all part of "programming". Don't ask permission to do your
job.

**Care** about your work. Care about your customers. The code we write allows the users of our code to get their shit
done, without our software getting in their way.

Always ask **"what problem am I trying to solve?"** This is such a great question to ask to gain clarity on what it is
exactly that you are doing. It helps you focus. This ties in nicely with Simon Sinek’s
[Start With Why](https://www.amazon.ca/Start-Why-Leaders-Inspire-Everyone/dp/1591846447).

In general, stick to solving **one problem at a time**. When you spot other problems, note them and come back to them
later.

**Be where you're at**. This is a life lesson that applies to software development. When you commit to doing something,
focus on doing it. When you're washing the dishes, focus on washing the dishes - forget all the things that stressed you
out that day. If you are spending time with your family, be there - turn off your phone, forget that tough problem
you've been wrestling with. When you're in a meeting, participate - focus on the conversation and forget about the work
that's piled up. Read "Zen Mind, Beginner's Mind" by Shunryu Suzuki

**SRP** has broader applications than just to code.

"Premature optimization is the root of all evil" - Donald Knuth. Start with a brute force algorithm until you find a
reason to change.

Ask **"what's the simplest thing that can possibly work?"** Read
[eXtreme Programming Explained](https://www.amazon.ca/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)
by Kent Beck. First version is supposedly more extreme than the second.

**Be OK with you**. You will never know everything - that is impossible. Keep learning, but don't get caught up on what
you don't know. Watch Kent Beck's talk
[Ease at Work](https://www.youtube.com/watch?v=yeA4CBInqKo&list=PLE47081AB99250873).

For me, Kent’s talk was a breath of fresh air. I’ve been a developer for over a decade and a half, and at times I get
it stuck in my head that the younger crowd already know the things that I know and more, and I’m an old, overpaid
developer. This isn’t the case (I hope), but this thought drives me to continuously learn so to not be left behind.
Kent’s talk is great because it helps you remember that it’s OK where you are. Even if there is a teenager prodigy
who can code circles around you, by and large that is atypical. I’m never complacent but how hard should I push to keep
up?

**Be humble**. Everyone is at different points of learning in their career. Help others on their path. Ask for help
when you need it. Give back to the community. Watch Leon Gersing's talk
[Truth, Myth and Reality in Software Development](https://www.youtube.com/watch?v=JIWvpPD3yQw).

I really enjoyed Leon’s talk Write “Hello World” in a new language, then delete it. Pairing with other developers helps
to understand where they are coming from, and helps you understand yourself.

I also like Leon’s talk because it ties together programming with Zen, both topics I find intriguing. Understanding
exactly what “Zen” is is a mind bend, ending in a place where Zen is everything and Zen is nothing. And some old Zen
master whacks a student, and the student finally “gets it” … or doesn’t.

For me, I’m here to figure out why I’m here. I like to “code”. How does that help the world be a better place? Who am I,
really? Can I find meaning by studying Zen? Taoism? I don't know if I’ll ever know the meaning of life, but I’ll
never stop searching.

**It's OK to be average** - Read the article
[In Praise Of The Average Developer](http://readwrite.com/2015/05/08/average-developer-10x-programmer-myth) - Why the
myth of the "10x" programmer is so destructive by Matt Asay. Matt Asay references Jacob Kaplan-Moss's
[keynote at PyCon 2015](https://www.youtube.com/watch?v=hIJdFxYlEKE).

**Multi-tasking is an illusion**. Computers get away with it because they can context switch really fast
(most of the time). Context switching for us mere mortals has a high cost. **Do one thing at a time, and do it well.**

9 women can't have a baby in a month. Read
[The Mythical Man Month](https://www.amazon.ca/Mythical-Man-Month-Software-Engineering-Anniversary/dp/0201835959)
by Fred Brooks.

**There is no spoon**. Just a reminder to lighten up a little bit. Have fun.
