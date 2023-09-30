# Trace Labs OSINT Field Manual

# Scope

This manual is meant to serve as a companion document to our OSINT VM, Onoing Ops and Search Party CTFs. Think of this as the printed version of one of our in person workshops. All techniques and considerations put forth in this manual will fall within the guidelines of the Search Party Rules of Engagement (ROE). Techniques will be passive in nature and every effort will be made to protect the participants, the subjects of the investigation and the investigation itself.

This manual will be focused on People-centric OSINT investigations. Expect to find discussion around social media investigations/techniques and geolocation but don’t be surprised by the absence of things like network infrastructure techniques or other non-people focused investigations. 

# Getting Started

### What is Open Source Intelligence?

We think of OSINT as any information that you as a regular citizen would have access to without possessing an sort of special accesses or clearances. For example, in the United States various members of the military or law enforcement will have access to databases of information the average citizen does not. These databases are not OSINT. 

What is or is not OSINT will differ based on your location. Based off the definition above, information considered “open source” in the United States may be protected under GDPR in the European Union so what is OSINT in the USA may not be OSINT in the EU.

OSINT is commonly associated with electronic research but this doesn’t have to be the case. Some pieces of OSINT may only exist as paper records in a courthouse or as microfiche in a public library. 

### What background or skills do you need to conduct an OSINT investigation?

The two most important characteristics an investigator can have are:

- Curiosity
- Discipline

Aside from those two universal characteristics it will be beneficial to have a background or understanding of the medium in which you will be investigating. For example:

- A social media / people focused (SOCMINT) investigation could require you to have a good understanding of how social media platforms work or how the subject of your investigation communicates and interacts with others.
- A Real Estate (REOSINT) focused investigation will require to have an understanding of how the buying and selling of property works in your area, where those records are kept and how you can access them.
- A network or infrastructure focused investigation will require to have an understanding of networked system. You would need to understand things like DNS and WhoIs records.

The bullet points above are just a few of the different flavors of investigation you could come across.  Also, a real world investigation could blend multiple types OSINT together. What starts out as a Network/Infrastructure investigation could quickly evolve in to a People based SOCMINT investigation as you try to understand who is behind a particular block of IP addresses or websites. 

The fundamentals of investigation haven’t changed but the places in which you conduct an investigation have evolved rapidly in recent years. 

### Why Use OSINT?

The amount of information available to the average person today is exponentially higher than it was for the people of previous decades. Not only are we putting more and more information “out there” willingly but more and more information is being collected, cataloged and sorted every single day. This explosion of accessible data has opened up the realm of investigation to an audience that would have been prohibited from it in years past. 

Leveraging Open Source Intelligence allows not only the average person to participate in an investigation but can also augment and enrich a more “traditional” style of investigation. Law Enforcement agencies around the world are incorporating OSINT in to more conventional “police work” with some larger agencies having dedicated OSINT analysts. 

Businesses leverage OSINT to protect and monitor their brand and reputation. Cybersecurity teams use OSINT to unmask the bad actors behind malicious infrastructure or connect different pieces of network infrastructure back to one central actor. 

Individuals can use OSINT when buying or home, going on a date or selecting a care giver for a child, pet or parent. The list could go on and on. The interesting thins is, almost all of us have been OSINTing our entire adult lives. We just didn’t know it was called that.

# Ethics

### “Right” vs “Legal”

We are not legal professionals and cannot advise you as to the legality of a potential investigation. This manual assumes you will stay in compliance with all applicable laws. With that being said, in many parts of the world it is not against the law to collect publicly available information. 

******************Just because something is not illegal doesn’t make it “right”.******************

It may not be against the law to keep tabs on your former romantic partners and their family and the new person they are dating and their families and so on…. but that’s really weird. It may not be against the law to do a deep dive in to all your coworker’s social media footprints and compile dossiers on they’re political leanings…. but that’s not necessarily a “right” thing to do. The list could go on but we hope you get the point. Just because there aren’t laws against collecting publicly available information doesn’t you don’t need a personal set of guidelines and guardrails.

### Responsibility of Investigators

You are responsible for your investigations. You are responsible for the impact of those investigations. You are responsible for the potential blowback and fallout from your investigations. You are responsible for how the insights provided by your investigation are leveraged. 

We use the term “responsible” above in the moral sense not the legal sense. As said before, we are not qualified to give legal advice. Ever. To anyone.

Before you undertake an investigation, you should ask yourself:

- Why am I doing this work?
- Who am I doing this work for?
- How will they be using the findings of my investigation?
- How will I be affected by bullet points above?
- How will the subject of my investigation be affected by the bullet points above?
- Am I ok with all the answers above?

# Safety

### Things to consider

OSINT is so amazing because anyone can do it. If you have a passion and a curiosity you can track down all kinds of information. As our world has gone more and more online the world of Open Source Intelligence is more approachable than ever. Realistically, anyone with a web browser can begin an investigation. 

And this is what can make OSINT very dangerous. A keyboard and monitor makes it easier to separate yourself from the subject of an investigation. Closing your laptop or logging off a social media platform can make you feel like you’ve “disconnected” from the actions of your investigation. This false sense of security or sense of detachment can put not only yourself at risk but also the subject of your investigation or even the investigation itself. 

### Your Safety

Ask yourself the following questions:

- What happens if someone else finds out what I’m doing?
- What happens if the subject of my investigation finds out about my investigation?
- Am I mentally prepared the subject matter I’ll encounter along the way?
- How do you feel about the answers to the questions above?

### Safety of Others

Ask yourself the following questions:

- Are my actions potentially jeopardizing someone else’s wellbeing?
- How do you feel about the answers to the questions above?

### Safety of the Investigation

Ask yourself the following question:

- Are my actions potentially jeopardizing the integrity of an ongoing criminal investigation?
- How do you feel about the answers to that question?

### Importance of Passive Reconnaissance

The sections above are typed out to drive home the importance of “passive reconnaissance”. The most important rule in the context of a Trace Labs event is passive recon. By not interacting directly with anyone during the investigation you will eliminate or mitigate all the concerns raised above. 

Passive reconnaissance protects not only you but other people and the investigation as a whole. What does this look like in real life?

- No interaction with ANYONE during an investigation. This includes DMs, emails, friend requests and interaction of social media posts of not only the subject of your investigation but anyone adjacent to your investigation.
- No talking about your investigation outside of safe channels
- Did we mention no interaction? Yeah. That one again

# Planning and Preparation

The first stage of the Intelligence Life Cycle involves planning. Before you begin “investigating” anything you need to do some pre-work. This planning will not only make your investigations more efficient but will keep you and your investigation safe as well. Good planning will also help you focus the techniques you employ and the medium in which you are investigating. 

### Define Your Mission

What are you trying to do? Seriously, write it down. Some useful prompts for the planning stage:

- What question are you trying to answer?
- What specific information are you looking for?
- What connection are you trying to make?

The more detailed and focused you are here, the more fruitful your investigation will be. Information you collect is just a “fact”. “Intelligence” is a collection of facts that support a specified mission or quest for information. 

### Define Success

When do you stop? You can keep digging forever but that wouldn’t be productive. At what point is your investigation over? Ideally, it would be when you’ve satisfied the requirements laid out previously in the planning stage but it’s still useful to define success. Knowing when to stop is a skill every investigator needs. 

### Define “Red Lines”

Similar but different to “Define Success” you need to define certain “red lines” that you will not cross and certain triggers that will end your investigation prematurely. This could be but not limited to:

- Discovering evidence of a serious crime
- Discovering subject matter you personally find triggering
- Your “online” investigation” spilling out in to the “real world”
- Finding yourself spending too much time thinking about an investigation
- Conducting an investigation having an adverse effect on your quality of life or of those around you

### OpSec

Operational Security….by the time you realize you need to be better at it it’s already too late. OpSec directly supports the Safety guidelines discussed previously. It’s also something that must be planned for before beginning and investigation. 

Think of OpSec as a spectrum: 

- The far left of the spectrum represents no effort at all. People at this end of the spectrum don’t care if everyone knows who they are, what they’re doing, what they’re saying, where they live, and so on….
- The far right of the spectrum represents maximum effort. People at this end of the spectrum are employing habits, routines and countermeasures to actively hide from organizations with nation-state level resources.

Every investigation will require you to be somewhere on this OpSec spectrum. The place you need to be on the OpSec spectrum will be dictated by your Threat Model in the context of the investigation you are conducting.  

Simply put, your Threat Model is you sketching out what threats you will encounter over the course of an investigation. The “amount” of OpSec you need you will be dictated by the threats you define in your model. Some good prompting questions to define your Threat Model: 

- Who/What are you hiding from?
- Will the subject(s) of your investigation be actively monitoring for investigations in to them?
- What action (if any) will the subject(s) of your investigation take against you if you are discovered?
- What are the consequences of your true identity being revealed?
- What are the consequences of your investigation being discovered?

In the context of Trace Labs we’ve attempted to build in “OpSec by default”. The Rules of Engagement we have for our investigations is a direct result of the answers to the above bullet points. For crowd sourced missing persons investigations, the risk to individual investigators is fairly low. The majority of the investigation will take place on social media platforms. In this context, you are not trying to “hide” your identity from the platform itself. Instead, you are obfuscating your true identity from other users of the platform. “Sock Puppet” accounts are must for SOCMINT investigations and something we encourage all of our volunteers to use.

*Note: This manual is written under the assumption that all platforms being interacted with are large commercial entities like Facebook, Twitter, Instagram, TikTok …. If your investigation takes you to infrastructure being managed by actors you would prefer to stay concealed from then consider using a VPN.*

### Sock Puppets

A “Sock Puppet” account is an alternate account you set up on a platform that other users of the platform could not easily tie back to your real life identity. The sock accounts you need to create will be defined by where your investigation is taking place. If you are investigating on a particular platform you need to have a sock puppet created for it. 

Creation and maintenance of sock accounts will differ from platform to platform. While the nuance and techniques of creation could fill its own manual some common themes hold true for sock accounts across platforms: 

- It’s getting harder to do. As platforms face scrutiny around bot activity on their platforms it has become harder to stand up alternate accounts.
- Mobile is your friend. Most platforms have a more “forgiving” account creation process when using their mobile app.
- Be as “normal” as possible. Creating an account from your residential IP address without a VPN and using a vanilla Chrome browser will appear less suspicious (from the platform’s perspective) than someone coming out of a Tor exit node.
- Don’t put in more effort than you have to. If your sock account doesn’t need an epic origin story, political affiliations and a personality than don’t worry about it.
- Don’t use other people’s headshots/profile pics from around the internet. This will get you in trouble.
- The absolute cleanest way to create sock accounts is to buy a disposable mobile phone and begin setting up on there from your home internet connection. After creation on mobile you should be able to log in from a desktop/laptop.
- Don’t get too attached to these accounts. They will get burned. It happens. Move on.
- Don’t mix up your sock accounts with your “real” accounts. This is where Virtual Machines and burner devices can be useful.

### Virtual Machines

VMs could fill out their own manual. A few bullet points around them:

- Virtual Machines offer you a great way to keep your investigation “isolated” from your normal computer usage. If you’re only signing in sock puppet accounts from within a VM there much less risk of your real account and your sock account “cross pollinating”
- VMs offer you a great way to stay organized. All the information around your investigation like notes and screenshots can be saved within your VM
- VMs can be disposable. When you’re done with an investigation you can easily delete the VM you were using.

# Techniques

Up to this point we’ve covered lots of important information. By now you should: 

- Understand the various uses of OSINT
- Understand the ethical and moral implications of your investigation
- Understand the importance of Passive Reconnaissance
- Have a clearly defined goal or mission that will dictate the end of your investigation
- Have clearly defined “red lines” that will trigger an end to your investigation
- Identified the platforms on which you will be investigating and created sock puppet accounts for those platforms
- Created a threat model for this investigation and put measures in place to counteract those threats

Now that all that preparation is done we can begin discussing various techniques you may find beneficial over the course of a people focused OSINT investigation. 

Reminder: All techniques discussed will be in the context of Trace Labs ROE. You will find some legitimate techniques missing from this list. We’ve chosen to expand on the techniques and principles we see most often over the course of a Search Party CTF or Ongoing Operation investigation.

### Understanding What You’re Starting With

What information do you have to start with? This will differ from investigation to investigation but in the context of a people based investigation you might have:

- Name
- Photo
- Physical description
- Social media profiles
- Hobbies
- Other information about them

The information you begin your investigation with will be the “source of truth” you’ll use to validate everything else you find over the course of your investigation. This validation is critical because if an incorrect piece of intel ends up in your investigation it can send you off in a completely wrong direction. 

Become very familiar with the information you are starting with as this will be the foundation of your entire investigation. 

### Seeing what’s in front of you

Seriously. What do you see? Go back to your original mission or original question. Does anything in front of you answer that question? Ever piece of intelligence you come across needs to be run through this “decision matrix”. Once you can reliably answer your question the investigation is over. 

### Enumeration

Enumeration is defined as “the act or process of counting something or a count made of something”

In the context of our investigations we will take something we already know, like a username, and try to find as many other places where that thing exists. Username enumeration is a powerful technique in the early stages of an investigation. 

- If you know a person’s preferred online handle, you will want to enumerate that handle across as many sites as possible. People reuse things all the time and names are no different.
- You can also enumerate their real name. Type it in to the search bar of your social media platform and see if you get any hits
- At the beginning of an investigation this could turn a single social media account into 7 accounts all linking back to your investigation

**WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING** 

Enumeration ≠ Validation. 

Just because you’ve found a person’s preferred handle on a website does not excplicitly prove it belongs to them. All you’ve done is prove that their preferred name exists on the site. Dig in to the new page you’ve found and find other things that tie back to the person:

- Same pictures from other social accounts?
- Same like/dislikes as  your person?
- Followed or Friended by another account belonging to your person
- Same group of people following and interacting with this new account as you’ve seen across other accounts

If you build your entire investigation on enumeration alone you’re going to have a very flimsy final product. 

### Pivoting

Pivoting is finding an piece of information that will send you somewhere else (likely another social media account)

Now that you’ve taken the time to find their social media accounts (thanks Enumeration!), what information can you find that will send you somewhere else? Some pivot points might look like:

- Links to other accounts. For example, on their Facebook page linking to their TikTok
- Friend or Follower accounts. It’s possible the subject of your investigation will be interacting with their friends under a different name on the same platform
- Friends and Followers mentioning other accounts in comments

**WARNING * WARNING * WARNING * WARNING * WARNING * WARNING * WARNING *** 

Don’t pivot immediately. Take the time to absorb what’s in front of you. Maybe there is a stronger or better pivot point further down the page. If you begin pivoting immediately you may find yourself going down a rabbit hole where you keep pivoting and forgot where you came from and how you got to where you currently are.

Go wide before you go deep.

### Photos + Videos

Some social media platforms will be more media driven than others. Ask yourself two things: 

- What do I know about the photo/video?
    - When was it taken/made?
    - Who posted it?
    - Who is interacting with it (like, emojis …)?
    - When was it posted? Does the content of the media sync up with when it was posted? For  example, if it’s winter and they’re  posting pictures with snow you may assume that it’s been made recently
- What is the photo telling me?
    - Does the media give clues to someones location?
    - Does the media give clues to someone’s state of mind?
    - Does the media give clues to someone’s friends or associates?
    - Does the media give insight into someone’s habits or addictions?
    - Are there any other pivot points or pieces of intelligence in the media? Think license plates, identification, work badge, business cards and so on…
    - Does the media answer your beginning question or accomplish your mission?

### Geolocation

This could be a topic for its own manual. The goal here is to determine the location featured in a piece of media. Where is it taking place at? This will be made much easier if you have other information to support this. Using the techniques above, hopefully you have somewhere to start your geolocation.

Similar to the photo/video section above:

- What do you know about the media?
    - Who took the photo or created the video? This could be a useful pivot point or something to at least narrow your geolocation. If your subject lives in New York and frequently posts New York pictures then this would be a good place to start your geolocation. Or if you know the poster was on vacation when the picture was posted then go back to  their social media and find out where they were on vacation and start your geolocation there.
    - When was it posted or shared? This could sync up with other activities your aware of (based off the techniques earlier in this guide) that will narrow your search or even answer the question for you
- What is the media telling you?
    - Notable landmarks? Can you see anything recognizable in the background
    - Time of day and time of year
    - If outdoors, overall geography. Mountains, desert, ocean and so on.
    - If indoors, clues about the architecture. Shape of light fixtures. Power outlets could give clues to country. Is it inside a hotel or someone’s home? If a hotel, does this correspond to travel they’ve been talking about?

# Resources

While this section is not exhaustive. We will attempt to include links to things we have found useful from our own experience

### Books

- Michael Bazzell “Open Source Intelligence Techniques”: [https://inteltechniques.com/](https://inteltechniques.com/)
- Rae Baker “Deep Dive”: [https://www.raebaker.net/](https://www.raebaker.net/)

### Videos

A free Joe Gray training conINT: [https://www.youtube.com/watch?v=EePeB9A2ZAk](https://www.youtube.com/watch?v=EePeB9A2ZAk)

Trace Labs Sock Puppet Panel Discussion: [https://www.youtube.com/watch?v=EEeJcZhxAf4](https://www.youtube.com/watch?v=EEeJcZhxAf4)

Trace Labs Sock Pupped explanation: [https://www.youtube.com/watch?v=3KPO58wkw7M](https://www.youtube.com/watch?v=3KPO58wkw7M)

Trace Labs Contestant Briefing: [https://www.youtube.com/watch?v=dYdQIiMzRlI](https://www.youtube.com/watch?v=dYdQIiMzRlI)

### Collections

Awesome OSINT: [https://github.com/jivoi/awesome-osint](https://github.com/jivoi/awesome-osint)

ohShint: [https://github.com/OhShINT/ohshint.gitbook.io](https://github.com/OhShINT/ohshint.gitbook.io)

### Tools

Username enumeration: [https://whatsmyname.app/](https://whatsmyname.app/)

Intel Techniques: [https://inteltechniques.com/tools/index.html](https://inteltechniques.com/tools/index.html)