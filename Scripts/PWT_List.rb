class AdvancedWorldTournament
    # List containing all possible tournament branches
    # Format per tournament is as following:
    #
    # "name of tournaments","condition == true"
    # trainer_entry[trainertype,trainername,endspeech_loose,endspeech_win,trainer variable,lobby text (optional), text before battle (optional), text after battle (optional)]
    # 
    # At least 8 entry arrays need to be defined per tournament name and condition
    # to make the tournament valid. A tournament with less than 8 trainers to fight,
    # will not show up on your tournament selection list.
      def fetchTournamentList
        tournament_list = [
          "Open Tournament","",
          # "Johto Leaders","",      <=  start of defining a new Tournament branch 
        ]
        # Open Tournament
        insertIndex = tournament_list.index("Open Tournament") + 2
    =begin
        tournament_list.insert(insertIndex,[:LEADER_Surge,"Surge","Now that's a shocker! You're the real deal, kid!",
                                            "Oh yeah! I'm strong!",1,
                                            "You are very strong! You're the victor! I'm not gonna lose! I'll train hard and be number one in Pokémon battling!",
                                            "You won't live long in combat! Not with your puny power!",
                                            "Oh no! You are very strong! But I will repay my debt someday."]) if paged?("SURGE")
        tournament_list.insert(insertIndex,[:LEADER_Erika,"Erika","Oh! I concede defeat. You are remarkably strong.",
                                            "I was afraid I would doze off...",1,
                                            "Oh! I admire your technique. It would make me very happy if I could battle with you again.",
                                            "This place doesn't really suit me, but...let's ignore that and battle!",
                                            "Losing leaves a bitter aftertaste... But knowing that there are strong trainers spurs me to do better..."]) if paged?("ERIKA")
        tournament_list.insert(insertIndex,[:LEADER_Sabrina,"Sabrina","Your power... It far exceeds what I foresaw... Maybe it isn't possible to fully predict what the future holds...",
                                            "Just as I foresaw...",1,
                                            "Your victory... It's exactly as I foresaw actually. But I wanted to turn that future on its head with my conviction as a trainer!",
                                            "Three years ago I had a vision of battling you. Since you wish it, I will show you my psychic powers!",
                                            "Psychic power isn't something that only a few people have. Everyone has psychic power. People just don't realize it."]) if paged?("SABRINA")
        tournament_list.insert(insertIndex,[:LEADER_Koga,"Koga","...If I am not strong enough to defeat you, there is but one thing to do. I must hone my skills.",
                                            "Hard work and discipline will always prevail!",1,
                                            "Don't expect to win next time! If you don't work on improving, I shall surpass you!",
                                            "Fwahahaha! I shall show you true terror as a ninja master! Opponents can't lay a hand on me, as poison brings their steady doom. Despair as you feel the creeping horror of Poison-type Pokémon!",
                                            "I subjected you to everything I could muster. But my efforts failed."]) if $pager.include?("KOGA")
        tournament_list.insert(insertIndex,[:LEADER_Blaine,"Blaine","I have burned down to nothing! Not even ashes remain!",
                                            "My flames are not something everyone can handle.",1,
                                            "Whoa hey! This time I'm sure of the victor's strength! Next time, I'll be even more of a raging inferno!",
                                            "Hah, you'd better have Burn Heal... \nOh wait, you can't use that here!",
                                            "Awesome. I have burned out... But the fire inside me is only going to get stronger! Let's battle again sometime!"]) if paged?("BLAINE")
        tournament_list.insert(insertIndex,[:LEADER_Giovanni,"Giovanni","Fuck this, I'm out!",
                                            "I could never have lost to a swine like you!",1,
                                            "Rich trash like you is the reason Team Rocket must scrounge things from other people. I will not lose the next time we meet!",
                                            "Having a kid stand in front of me like this... Such a thing should never happen. But for some reason, it also makes me feel nostalgic. If you insist, I will make you feel a world of pain!",
                                            "Privileged youth is the cause of all the world's problems these days..."]) if paged?("GIOVANNI")
    =end
        tournament_list.insert(insertIndex,[:LEADER_Misty,"Misty","Know what? My dream was to go on a journey and battle powerful Trainers... I made my dream come true, and now... my next dream is to someday defeat you!",
                                            "See! This is the Water-type toughness I was talking about!",1,
                                            "My pride and joy are my Water-type Pokémon. But they were no match for yours. Thank you for teaching me the world is a really big place.",
                                            "Hey everyone! I'm Misty, Cerulean City's Gym Leader! I'm a user of Water-type Pokémon! #{$Trainer.name}, are you good enough to beat me?",
                                            "I lost... I need to try swimming around for a bit so that I can clear my head of these feelings. ...I definitely won't lose next time!"]) if paged?("MISTY")
        tournament_list.insert(insertIndex,[:RIVAL_Aria,"Aria","Maybe you've outperformed us today...",
                                            "Battling isn't for everyone... As you know, I've been in a similar place before.",1,
                                            "Hey, #{$Trainer.name}! I've actually battled a few times in Kalos, you know... My most memorable was against one of my performing rivals named Serena. I'd really like to see her again soon. Maybe she'll show up to the PWT!",
                                            "It's me, Aria, the reigning Kalos Queen! We're going to blow you away with this performance. Watch out, #{$Trainer.name}!",
                                            "I still have much to learn about Pokémon battling. You should try performing someday!"]) if paged?("ARIA")
        tournament_list.insert(insertIndex,[:RICHBOY,"Winston","Humph! I didn't think it would happen like this again...",
                                            "I knew things would go differently this time! My frustration was clouding my judgement last time!",1,
                                            "I thought my anger was clouding my judgement when we first battled, but now I see that you're just the better trainer...",
                                            "Remember me? When we first met, you ruined my date... But then you saved it. I'm not sure whether to thank you or berate you.",
                                            "Now you've ruined my day as well! I demand another apology!"]) if paged?("WINSTON")
        tournament_list.insert(insertIndex,[:AROMALADY,"Petunia","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarrass a lady in public as well..."]) if paged?("PETUNIA")
        tournament_list.insert(insertIndex,[:LEADER_Anthony,"Anthony","Damn, #{$Trainer.name}! I knew you would become strong since our battle, but I didn't expect you to go all out on your big bro!",
                                            "Guess I can still teach you some stuff from time to time, right?",1,
                                            "#{$Trainer.name}! Never thought I'd see you here so soon! Just because you're my little sibling doesn't mean I'll take it easy, got it?",
                                            "You may have bested me before, pipsqueak, but now I'll show you why I love Bug-type Pokémon!",
                                            "Ah, geez... To be beaten not once, but multiple times by a younger sibling... What kind of older brother am I?"]) if paged?("ANTHONY")
        tournament_list.insert(insertIndex,[:LEADER_Scarlett,"Scarlett","You still haven't put down the flame inside of me! I'll show you why I was able to run this tournament for so long!",
                                            "I may be older than you, but that doesn't mean I lack fighting spirit! Hit me with your best shot, kiddo!",1,
                                            "I'm glad to see you came, #{$Trainer.name}. I hope I can show you why I dedicate myself to help other trainers achieve their best.",
                                            "The crowd is watching, #{$Trainer.name}! Give them a real battle that will scorch their souls!",
                                            "Oh well, guess we can't beat them all. Still, I'm happy to see such a young face growing up... Reminds me of myself..."]) if paged?("SCARLETT")
        tournament_list.insert(insertIndex,[:CELESTIAL_Astra,"Astra","Oh my, what a deep connection between trainer and Pokémon!",
                                            "Angel and I are one alike, even when separated. I can tell that she's supporting me just by our bond.",1,
                                            "I foresaw our meeting, #{$Trainer.name}, and I must say I'm pleased to be able to battle you again. Now, show me how terrific you are in battle.",
                                            "#{$Trainer.name}, do show me the extent of your powers. I will demonstrate what months of training can do to improve oneself.",
                                            "So in the end, my mind fell against matter... No, I'm sure it was your battle prowess that gave you the win. You're a noble trainer, #{$Trainer.name}, I'll keep an eye on you."]) if paged?("ASTRA")
        tournament_list.insert(insertIndex,[:LEADER_Skyler,"Skyler","Oh my, it seems that my elegant birds are not capable of flight any longer...",
                                            "This is where you shall meet your demise, #{$Trainer.name}! Prepare for your own Swan Song!",1,
                                            "It seems we meet again, #{$Trainer.name}. May the wind always be at your back, for I will best you nonetheless!",
                                            "You may be Anthony's younger sibling, but in this arena, we are all only trainers. Prepare yourself, #{$Trainer.name}, for I am taking flight!",
                                            "...Very well. It seems that I have lost again. There is just something about your family that intrigues me..."]) if paged?("SKYLER")
        tournament_list.insert(insertIndex,[:LEADER_Florinia,"Florinia","Very well...",
                                            "Hypothesis confirmed. Subject does not possess the necessary strength to prevail.",1,
                                            "I might wish you \"Good luck\" in this tournament, however \"luck\" is merely an illusory essentialization of statistics, and is neither inherently good nor bad.",
                                            "Audience, observe the following example of standard battling procedure. Hypothesis: Subject displays insufficient data for conclusive success. Expected outcome: Failure.",
                                            "You exhibit qualities that indicate excitement. Enjoyment is a triviality. Only function matters."]) if paged?("FLORINIA")
        tournament_list.insert(insertIndex,[:REGALDAME,"Chelsea","Ugh! You filthy children are the bane of my existence! First my own son and now you?!",
                                            "Most obviously. A child like you could not beat me in a million years! ...What? You look surprised... Get used to it!",1,
                                            "If it isn't the little brat from back then. As you can see, this is really the only place I can be at peace, so back off.",
                                            "Brat, I won't allow you to go any further! This place shouldn't be infested with insolent vermin like you!",
                                            "...What?! How did I lose to a child? Did my son put you up to this? That prick is gonna get a beating when I get home!"]) if paged?("CHELSEA")
        tournament_list.insert(insertIndex,[:RIVAL_Cole,"Cole","...I will overcome this challenge and make my Clan proud! I must win this, for my family's sake!",
                                            "In this myriad of environments, I was bound to come up on top. I'm always able to adapt myself, no matter the difficulty.",1,
                                            "#{$Trainer.name}. What a sight for sore eyes. Despite my dislike for big cities, I couldn't pass the chance to learn about so many new surroundings like this.",
                                            "Adaptability is the answer to all, #{$Trainer.name}. It matters not who the enemy may be; those who can't adapt are the first to fall.",
                                            "I put shame on my clan's name... I shan't show myself in public after this..."]) if paged?("COLE")
        tournament_list.insert(insertIndex,[:LEADER_Whitney,"Whitney","H-hey! Me? Losing? But... I can't lose, you hear?",
                                            "You really are strong, but I'm not weak either!",1,
                                            "Back home in Goldenrod City, everyone was into Pokémon, so I got into it too!",
                                            "Hi again! You want to battle? I'm warning you, I'm good!",
                                            "Sob... ...Waaaaaaah! You...you...Waaaaah!"]) if paged?("WHITNEY")
        tournament_list.insert(insertIndex,[:RIVAL_Aurelia,"Aurelia","Ugh, whatever, like, you're not even that good or anything, got it?",
                                            "Hah, see? You're completely useless when it comes to battles, unlike me!",1,
                                            "Huh, so I have to, like, battle you? Like, for sure I'm winning and becoming famous after this!",
                                            "So, like, you didn't even run from fear? Now I'll show you how you're SO last season!",
                                            "Like, whatever! I get it, you're the better trainer... Battling is totally for nerds, for sure!"]) if paged?("AURELIA")
        tournament_list.insert(insertIndex,[:RIVAL_Brady,"Brady","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("BRADY")
        tournament_list.insert(insertIndex,[:TRAINER_Mira,"Mira","Oh no. You're too much for me!",
                                            "Mira is showing you that Mira is much stronger than you thought!",1,
                                            "Don't mind me in this tournament, I just wanted to show everyone how strong Mira is!",
                                            "Mira is really strong! Please, battle with Mira!",
                                            "Mira wonders if she could get far in this tournament..."]) if paged?("MIRA")
        tournament_list.insert(insertIndex,[:TRAINER_Cheryl,"Cheryl","Ugh, I can't keep up...",
                                            "Just the right balance of offense and defense...",1,
                                            "I would've never been able to get into the PWT by myself. Thank you so much, #{$Trainer.name}.",
                                            "Oh, hello there. Are you my opponent for the day?",
                                            "Thank you. Now my adorable Pokémon became a little bit tougher."]) if paged?("CHERYL")
        tournament_list.insert(insertIndex,[:RIVAL_Hop,"Hop","The sting of defeat and the joy of victory... I guess experiencing both is the key to us getting stronger, right?",
                                            "Undefeated! And my Pokémon's moves were seriously on point!",1,
                                            "I recently lost in the Galar Tournament, but I think it's a good idea to try my luck in this tournament. I wanna see how others do, too!",
                                            "It's time for my legend to begin!",
                                            "Oof! Gutted that I lost... But I'd expect nothing less!"]) if paged?("HOP")
        tournament_list.insert(insertIndex,[:OFFICEWORKER_F,"Trisha","Wonderful.",
                                            "A truly spectacular battle has both its fiery and calm moments, and this was the perfect balance for me.",1,
                                            "Oh, it's you. I just wanted to thank you again for helping our family out that one time. We're doing a lot better now!",
                                            "Don't think I will go easy on you because of your help earlier. Here we come!",
                                            "Nonetheless, I am at peace..."]) if paged?("TRISHA")
        tournament_list.insert(insertIndex,[:OFFICER,"Hank","Well darn...",
                                            "True strength comes through intense training. Looks like you'll need to work on that a bit for next time...",1,
                                            "Hey #{$Trainer.name}. Make sure to stop by in Stiffrack City someday!",
                                            "I've been waiting for this moment. Don't hold back!",
                                            "Next time we will be stronger; just wait!"]) if paged?("HANK")
        tournament_list.insert(insertIndex,[:PRESCHOOLER_F,"Hannah","Nononono!",
                                            "Yay! I'm going to use daddy's Pokémon every time!",1,
                                            "Whoa, there are a lot of people here. Everyone seems older than me...",
                                            "Yay, I've been waiting to find you! You were a lot of fun to play with last time!",
                                            "You're no fun! I'm going to play with Jojo instead!"]) if paged?("HANNAH")
        tournament_list.insert(insertIndex,[:PRESCHOOLER_M,"Jojo","I'm going to take mommy's Pokémon next time.",
                                            "Haha, my Pokémon are gooder than yours!",1,
                                            "Have you seen Hannah? I got distracted when I lost one of daddy's Pokémon but I couldn't find her again afterwards...",
                                            "Ooh! Let's play!",
                                            "These Pokémon are no good... Why would daddy use them?"]) if paged?("JOJO")
        tournament_list.insert(insertIndex,[:BIRDKEEPER,"Roy","Back to training it is...",
                                            "There's no way we could've lost!",1,
                                            "Just you wait, we're going to be the next Champion, Pidgeot and I!",
                                            "You're about to feel the wrath of the strongest bond between trainer and Pokémon!",
                                            "This taste of defeat... It's worse than the bird food Pidgeot and I eat every day."]) if paged?("ROY")
        tournament_list.insert(insertIndex,[:REGALKNIGHT,"Spencer","What? Such a brave heart for such a young child!",
                                            "The Grey Knight once again bests its foes, and bathes in their sorrows!",1,
                                            "#{$Trainer.name}, how nice to see you here. We may have different opinions on important matters, but I believe in chivalrous battles.",
                                            "Unsheath your sword, trainer! Our battle is sure to be a clashing of powerful wills!",
                                            "So in the end, the Grey Knight fell. I dragged my liege's name through the mud. This is the utmost disrespect this title can bring..."]) if paged?("SPENCER")
        tournament_list.insert(insertIndex,[:ROCKET_Proton,"Proton","Seriously, you'd chase me this far?!",
                                            "Just as expected. I won!",1,
                                            "I'm going to show Team Rocket's true capacity. Don't try interrupting me!",
                                            "Don't expect any mercy from me!",
                                            "Grr... For another kid to be this good..."]) if paged?("PROTON")
        tournament_list.insert(insertIndex,[:LEADER_Rocco,"Rocco","Ugh, this really sucks...",
                                            "Haha, see? I told you, I ain't going easy, pal.",1,
                                            "Ay, partner. So you were invited by Scarlett too, huh. I hope you're prepared to see what I can really do, and it won't be so easy.",
                                            "Hope you're ready to see the power of my Rock-type Pokémon. They're gonna put you in your place.",
                                            "...Oh well. But it was funny, good work."]) if paged?("ROCCO")
        tournament_list.insert(insertIndex,[:CELESTIAL_Angel,"Angel","What do you mean? Oops, did I just lose?",
                                            "Wow, you really chose that strategy? I could see that coming from miles away, even without ESP...",1,
                                            "...Why am I here again?",
                                            "Okay... I guess since I'm already here, no use in avoiding this... Let's just get this over with.",
                                            "*Tsk* At least it's over. Now I can go back to... What was I doing again?"]) if paged?("ANGEL")
        tournament_list.insert(insertIndex,[:LEADER_Chili,"Chili","Aww, man! I was all fired up, too!",
                                            "As if that would work on my Pokémon!",1,
                                            "You're scorching everyone, huh? That's amazing! I want to win too! I'll be known as Chili, the world's best trainer of Fire-type Pokémon!",
                                            "Ta-da! The Fire-type scorcher Chili, that's me, will be your opponent!",
                                            "You got me. I am... burned... out..."]) if paged?("CHILI")
        tournament_list.insert(insertIndex,[:LEADER_Falkner,"Falkner","We can still fly!",
                                            "The wind is finally with us!",1,
                                            "I've been waiting to see you! ...Well, let's get going to the tournament.",
                                            "I'll show you the real power of Flying-types!",
                                            "Mmm... I still have a long way to become the best trainer..."]) if paged?("FALKNER")
        tournament_list.insert(insertIndex,[:RIVAL_Fern,"Fern","Whatever... I don't want to waste my time with you anymore anyway.",
                                            "You really went down that quickly? What a sorry excuse for a trainer!",1,
                                            "Huh? Got a problem? Get out of my face! You're not worth my time.",
                                            "I'm the cool cat, and the top dog. Got it? Cuz I don't think you do. Get ready for a lesson in class!",
                                            "Hah! Way to get lucky. Later, loser!"]) if paged?("FERN")
        tournament_list.insert(insertIndex,[:RIVAL_Hugh,"Hugh","I won't forget the pain you just put my partner through!",
                                            "That was good enough! Cool!",1,
                                            "Hey, how are you? I'd like to find my rival here, you know. You must have rivals too; you're a trainer after all...",
                                            "Let's see how good of a trainer you are! I'll use my Pokémon with everything they've got!",
                                            "It can't be! How could I have lost? I need to apologize to my partner..."]) if paged?("HUGH")
        tournament_list.insert(insertIndex,[:SUBWAYBOSS_Ingo,"Ingo","Bravo! You showed me the spark of trainers. However, let me say just one thing... Please move on to an even greater goal!",
                                            "I'm winning this time, but you have talent! Your tactics... reading... You have great skills. That's right! I would like to battle you again and again!",1,
                                            "Don't mind me; I'm just one of the siblings who run the Battle Subway in Unova.",
                                            "Do you understand Pokémon well? Can you hold onto your principles? Will you go onto victory, or defeat? All aboard!",
                                            "Bravo! Excellent! I am glad that I fought so hard against a wonderful trainer like you. That's right! We grow stronger by matching ourselves against a strong opponent."]) if paged?("INGO")
        tournament_list.insert(insertIndex,[:LEADER_Brock,"Brock","Looks like you were the sturdier of us.",
                                            "I'm rock-hard right now!",1,
                                            "You were pretty tough! I can't wait to face off against you again!",
                                            "I believe in rock hard defense and determination. Let's see if yours is harder!",
                                            "The world is huge. There are still many strong trainers like you. Just wait and see. I'm going to become a lot stronger, too."]) if paged?("BROCK")
        tournament_list.insert(insertIndex,[:ROCKET_James,"James","NO! Jessie is going to kill me. Looks like Team Rocket's blasting off again!",
                                            "We were just getting to the good part!",1,
                                            "Huh, even Jessie and I were allowed in this tournament... They really accept everyone, even people like us, haha.",
                                            "Surrender now, or prepare to fight!",
                                            "I'm going to be blasted off, except this time by Jessie."]) if paged?("JAMES")
        tournament_list.insert(insertIndex,[:LEADER_Julia,"Julia","Huh? I lost already?",
                                            "All right, all right, all right! Now I'm wired!",1,
                                            "Hey, #{$Trainer.name}. Just in case you forgot, I'm a cheer captain and the Electric-type Gym Leader from the Peridot Ward in Reborn City! I hope you're ready to go BOOM!",
                                            "OTS, we represent! We pack a punch and don't relent!",
                                            "Whateverrrrr, I'm gonna go take a power nap."]) if paged?("JULIA")
        tournament_list.insert(insertIndex,[:TRAINER_Lucas,"Lucas","That was an invigorating battle! It will certainly help me with my research for Professor Rowan.",
                                            "Oh wow! I'm not much of a trainer, but it seems like I've emerged victorious today!",1,
                                            "Would you like to ever visit Sinnoh? If you do, you should check out the Fight Area there!",
                                            "Hi #{$Trainer.name}! Let's see how this battle goes.",
                                            "I'm looking forward to our next battle. This one was memorable."]) if paged?("LUCAS")
        tournament_list.insert(insertIndex,[:CAPTAIN_Mallow,"Mallow","Sure enough, when it comes to you and Pokémon, the quality of the ingredients shines forth!",
                                            "You'll taste defeat when you can't draw out the excellence of your Pokémon.",1,
                                            "You know, I think that, with your Pokémon, we can produce a flavor that no one can imagine!",
                                            "Time for everyone to see that I can do more than just cooking!",
                                            "This battle was a piece of cake for you, wasn't it?"]) if paged?("MALLOW")
        tournament_list.insert(insertIndex,[:LEADER_Brawly,"Brawly","Wow! I've been swamped by your skills.",
                                            "Alright! I rode the big wave!",1,
                                            "Your skills are top notch... You really make a big splash!",
                                            "So you want to challenge me? Let me see what you're made of!",
                                            "Whoa, wow! You made a much bigger splash than I expected!"]) if paged?("BRAWLY")
        tournament_list.insert(insertIndex,[:PLASMA_Colress,"Colress","Just as I expected. Your Pokémon must be happy to be by your side! You bring out the best in their power!",
                                            "What's this? I just know you can bring out more power from your Pokémon!",1,
                                            "By having battles with many trainers, I can bring out the true potential of my Pokémon! Eventually, as I continue to battle, the truth of my theory will be evident to all!",
                                            "Well then... I will test you to see if you can bring out the hidden potential of your Pokémon!",
                                            "Splendid! You are quite the trainer!"]) if paged?("COLRESS")
        tournament_list.insert(insertIndex,[:ROCKET_Jessie,"Jessie","Ugh! You're such a twerp! Looks like Team Rocket's blasting off again...",
                                            "What?! Did we just win? I... I didn't think that was possible! James, get the camera!",1,
                                            "Next time it's going to be the perfect time to show Team Rocket's potential, just watch!",
                                            "Prepare for trouble!",
                                            "Well, Team Rocket failed again... Should I be surprised?"]) if paged?("JESSIE")
        tournament_list.insert(insertIndex,[:ROCKET_Petrel,"Petrel","What? How did I lose?!",
                                            "Hahaha. I doubted a child like you would get this far...",1,
                                            "If you think you're gonna stop Team Rocket here... Well, that's not going to happen!",
                                            "This time I won't hold back! Give me all you've got!",
                                            "I... I couldn't do a thing. Giovanni, please forgive me..."]) if paged?("PETREL")
        tournament_list.insert(insertIndex,[:RIVAL_Gladion,"Gladion","How annoying...",
                                            "You can't beat me. You'll just get your Pokémon hurt for no reason.",1,
                                            "Please just leave me alone. There are a lot of other people you can talk to here.",
                                            "Battle me. I won't take no for an answer.",
                                            "Hmph... It's not like me to slip up like that. I've got to keep fighting stronger opponents. Looks like I'm still not ready..."]) if paged?("GLADION")
        tournament_list.insert(insertIndex,[:LEADER_Roark,"Roark","No way! Not yet...",
                                            "See? I'm proud of my rocking battle style!",1,
                                            "With skills like yours, It's natural for you to be succeeding.",
                                            "I need to see your potential as a trainer. And, I'll need to see the toughness of the Pokémon that battle with you!",
                                            "W-what? That can't be! My buffed-up Pokémon!"]) if paged?("ROARK")
        tournament_list.insert(insertIndex,[:RIVAL_Silver,"Silver","...Humph! You're doing okay for someone weak.",
                                            "Don't try getting in my way; this is what happens!",1,
                                            "Why am I here? Such a waste of time...",
                                            "You look really weak, but I'll give you the opportunity to prove me wrong. Show me you're not a weakling!",
                                            "...Humph! What a waste."]) if paged?("SILVER")
        tournament_list.insert(insertIndex,[:LEADER_Viola,"Viola","Ohhh! No one enjoys losing, but you all were such great opponents!",
                                            "The photo from the moment of my victory will be a real winner. Alright!",1,
                                            "Even in another region, I'm always looking for the perfect shot. Very interesting, right?",
                                            "That determined expression... That glint in your eye that says you're up for challenges... It's fantastic! Now come at me! My lens is always focused on victory; I won't let anything ruin this shot!",
                                            "You and your Pokémon have shown me a whole new depth of field! Fantastic! Just fantastic!"]) if paged?("VIOLA")
        tournament_list.insert(insertIndex,[:LEADER_Milo,"Milo","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("MILO")
        tournament_list.insert(insertIndex,[:RIVAL_Marnie,"Marnie","I respect you as a challenger and all, but I got too much at stake to go around losin' now!",
                                            "Don't look so angry. It's no big deal.",1,
                                            "Oh, hey. Sorry if you see any Team Yell members in here; they're a bunch of my fans.",
                                            "I'd wish you luck, but I'm afraid I'm gonna be the one who wins.",
                                            "You beat me... Guess you must not be too bad after all, huh?"]) if paged?("MARNIE")
        tournament_list.insert(insertIndex,[:RIVAL_Amanda,"Amanda","This is definitely something I was not planning.",
                                            "Better strategy is always the answer!",1,
                                            "You fight just like the Champion from Aevium. Take that as a compliment~.",
                                            "I heard so much about you. Let's see what you got!",
                                            "You're totally great!"]) if paged?("AMANDA")
        tournament_list.insert(insertIndex,[:METEOR_Taka,"Taka","Looks like you did the thing. Darn.",
                                            "Oh, did I just win? Looks like I'll be the one who has to keep going...",1,
                                            "By the way, do you have any idea what we're doing here? I mean, if not, it's cool. Frankly, I've never once in my life known where I was going...",
                                            "...Oh, yes, orders. After all, I'm with Team Meteor... And, sorry to say, it seems my current order is to battle and defeat you so that I can advance in the tournament. So... don't take it personally or anything, all right?",
                                            "Hm. Well, I tried..."]) if paged?("TAKA")
        tournament_list.insert(insertIndex,[:LEADER_Burgh,"Burgh","Could it be possible that my strings are being severed?!",
                                            "This is the time to leave your cocoon and show the crowd your real potential!",1,
                                            "Well, hello there. I hope we get to create a masterpiece out there!",
                                            "Now, come young one and show us your feelings through this batte!",
                                            "I guess I wasn't able to properly match your feelings with my own..."]) if paged?("BURGH")
        tournament_list.insert(insertIndex,[:LEADER_Corey,"Corey","Youth will again and again break their spirits upon the crags of life.",
                                            "Your resilience is admirable, but foolish.",1,
                                            "Perhaps you think that winning against me gives you hope for your future battles? ...Hope is weakness. It's an illusion meant to sugarcoat this sickening reality...",
                                            "I will show you the cruelty of what is real!",
                                            "Savor this victory. For every joy, bitter misery rushes after."]) if paged?("COREY")
        tournament_list.insert(insertIndex,[:TRAINER_Dawn,"Dawn","I'm sorry...",
                                            "United like this, our dream team has no chance of losing!",1,
                                            "I'm pretty good in a Pokémon battle, but when it comes to anything else, I can be a little scatterbrained. So, somebody else usually ends up having to bail me out...",
                                            "Don't worry about who has more experience! Let's just push each other to grow stronger like rivals do!",
                                            "Ehaha! That's the power of teamwork."]) if paged?("DAWN")
        tournament_list.insert(insertIndex,[:CHAMPION_Blue,"Blue","How the heck did I lose to you?",
                                            "This is what I, Kanto's top-level trainer, can really do!",1,
                                            "Bonjour! Off for an adventure? That's fine and all, but don't forget to have a battle with me from time to time! Anyway, smell you later!",
                                            "Right now, I'm really in the mood for a battle!",
                                            "How did I lose? You really are the real deal!"]) if paged?("BLUE")
        tournament_list.insert(insertIndex,[:TRAINER_Fuji,"Fuji","I'm so sorry, my friends.",
                                            "We're doing a great job.",1,
                                            "Our battle was a spectacular show, and I could see the love you carry for your Pokémon. That's something truly beautiful.",
                                            "We can do this, my dear friends.",
                                            "Not this time, I guess."]) if paged?("FUJI")
    =begin
        tournament_list.insert(insertIndex,[:XEN_Zetta,"Zetta","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("ZETTA")
        tournament_list.insert(insertIndex,[:SCHOOLKID_M,"Billy","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("BILLY")
        tournament_list.insert(insertIndex,[:LEADER_Nessa,"Nessa","They washed us away.",
                                            "We'll be reeling in a victory!",1,
                                            "No matter what kind of plan your refined mind may be plotting, my partner and I will be sure to sink it.",
                                            "My partner and I are gonna flood the battlefield and make it our ocean. I'll show you why they call me the raging wave!",
                                            "Next time, me and my Pokémon will be more refined than ever."]) if paged?("NESSA")
        tournament_list.insert(insertIndex,[:SKULL_Plumeria,"Plumeria","Yeah, yeah, you win.",
                                            "Is that all you got?",1,
                                            "The poisonous gas my partner Pokémon Salazzle releases can be used to make perfume. As it is, it's dangerous, but if you dilute it, it becomes a great-smelling perfume.",
                                            "I don't believe that people understand each other if they battle, but I'll face you anyway.",
                                            "Hmph! You're pretty strong. I'll give you that. But mess with anyone in Team Skull again, and I'll show you how serious I can get."]) if paged?("PLUMERIA")
        tournament_list.insert(insertIndex,[:TRAINER_Brigette,"Brigette","Aw, I was just getting started...",
                                            "And that's how we do it!",1,
                                            "It was really cool to work with my sister on the Pokémon Storage System and to bring it to the Hoenn region. It really is something fascinating.",
                                            "Allow me to see all the different kinds of Pokémon you carry!",
                                            "All these Pokémon... I wish I had them all!"]) if paged?("BRIGETTE")
        tournament_list.insert(insertIndex,[:TRAINER_Lanette,"Lanette","I mean, I'm good with technology, not Pokémon, sadly.",
                                            "Wait, I did that? Wow!",1,
                                            "It was so cool seeing the similarity between Castform and Deoxys in my studies. To think that these two would have something in common...",
                                            "Please show me all the kinds of Pokémon out there!",
                                            "That was fun. Let's battle again sometime."]) if paged?("LANETTE")
        tournament_list.insert(insertIndex,[:LEADER_Kenneth,"Keta","This intense feeling that floods me after a defeat... I don't know how to describe it.",
                                            "Harrumph! I know your ability is greater than that!",1,
                                            "I may be old, but I desire victory! This desire is the energy for life! It's the power to surpass who I was the previous day! I compliment you on your victory, but next time, victory will be mine!",
                                            "What I want to find is a young trainer who can show me a bright future. Let's battle with everything we have: your skill, my experience, and the love with which we've raised our Pokémon!",
                                            "Wonderful. I'm grateful we had a chance to meet and battle. Make a bright future-not just for yourself, but for others as well."]) if paged?("KENNETH")
        tournament_list.insert(insertIndex,[:LEADER_Cilan,"Cilan","Huh? Is it over?",
                                            "What a surprise... You are very strong, aren't you? I guess my brothers wouldn't have been able to defeat you either...",1,
                                            "You...are very strong. Would you team up with me sometime? There's still much I want to learn.",
                                            "Nothing personal... No hard feelings... Me and my Grass-type Pokémon, um... We're gonna battle, come what may. I'm looking forward to battling with you.",
                                            "Well... I'm just glad I was able to bring out the delectable charm of Grass-type Pokémon. I lost, though... Well, more importantly, congratulations!"]) if paged?("CILAN")
        tournament_list.insert(insertIndex,[:TRAINER_Concordia,"Concordia","Ho? Not bad!",
                                            "In the aftermath of the furious battle... I feel as pure and refreshed as when the sky clears after a storm.",1,
                                            "I'm going to win my way through every round, then I'll be the one taking on Leon! If I don't, then I'll have failed to repay Duraludon and the rest of my team for all their hard work!",
                                            "I'm going to defeat everyone, win the whole tournament, and prove to the world just how strong the great Raihan really is!",
                                            "I might have lost, but I still look good. Maybe I should snap a quick selfie..."]) if paged?("CONCORDIA")
        tournament_list.insert(insertIndex,[:TRAINER_Dexio,"Dexio","You are positively shining! Yes, it's important to always shine.",
                                            "I just had the perfect strategy, but you should keep doing your best!",1,
                                            "It's not battle results that interest me. Rather, it's the carefully-thought-out strategies or novel tactics employed by trainers. How those plans affect one's opponent and influence the outcome of battles, that is where my interest lies!",
                                            "In a sense, this is a trial. A trial to see whose battle strategy will succeed!",
                                            "Yes! You have emerged victorious!"]) if paged?("DEXIO")
        tournament_list.insert(insertIndex,[:LEADER_Venam,"Venam","You certainly are an unmatched talent!",
                                            "That was an extraordinary effort from both you and your Pokémon!",1,
                                            "That was an impressive battle! The spirit of my first partner, Larvesta - no, Volcarona - lives on in my current partners, too! I want to add your strength to their experience as well!",
                                            "I show everyone how wonderful it is to move forward together with Pokémon. Competing like this is probably the best way to show everyone!",
                                            "Well done! The ones who change the world are always the ones who pursue their dreams. That's right! They're just like you."]) if paged?("VENAM")
                                            
        tournament_list.insert(insertIndex,[:ELITE_Karen_1,"Karen","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("KAREN_R")
        tournament_list.insert(insertIndex,[:CAPTAIN_Mina,"Mina","Huh! That was surprising.",
                                            "An artist's touch.",1,
                                            "Back in Alola, we have this Pokémon called Shiinotic. The way they move their little bodies around is really unique--I make them the subject of a lot of my paintings. Although, if you stare at them long enough, you'll start to get sleepy.",
                                            "Here we go!",
                                            "Woah! I'm shocked at your strength!"]) if paged?("MINA")
        tournament_list.insert(insertIndex,[:KAHUNA_Olivia,"Olivia","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("OLIVIA")
        tournament_list.insert(insertIndex,[:TRAINER_Rorim,"Rorim B.","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("RORIMB")
        tournament_list.insert(insertIndex,[:LEADER_Flora,"Flora","The sting of defeat and the joy of victory... I guess experiencing both is the key to us getting stronger, right?",
                                            "Undefeated! And my Pokémon's moves were seriously on point!",1,
                                            "I recently lost in the Galar Tournament, but I think it's a good idea to try my luck in this tournament. I wanna see how others do, too!",
                                            "It's time for my legend to begin!",
                                            "Oof! Gutted that I lost... But I'd expect nothing less!"]) if paged?("FLORA")
        tournament_list.insert(insertIndex,[:LEADER_Aya,"Aya","I never wanted any of this...",
                                            "No, you don't get it. I really don't care.",1,
                                            "I'm not sure why I'm even here. I guess there's just nothing else to do. I'd be better off if everyone just left me alone. You can go now.",
                                            "I don't even really want to do this, but I don't have other options anyway, so let's get this over with.",
                                            "...I lost... At least I won't have to deal with this again."]) if paged?("AYA")
        tournament_list.insert(insertIndex,[:CHAMPION_Lance,"Lance","All right! I thought this would never happen!",
                                            "I never give up, no matter what. You must be the same.",1,
                                            "You have become truly powerful, #{$Trainer.name}. Your Pokémon have responded to your strong and upstanding nature. As a Trainer, you will continue to grow strong with your Pokémon.",
                                            "I've been waiting for you! I knew that you, with your skills, would eventually reach me here. There's no need for words now. We will battle to determine who is the stronger of the two of us.",
                                            "...It's over. But it's an odd feeling. I'm not angry that I lost. In fact, I feel happy. Happy that I witnessed the rise of a great new trainer!"]) if paged?("LANCE")
        tournament_list.insert(insertIndex,[:TRAINER_Cal,"Cal","This feels empty.",
                                            "Maybe I shouldn't have gotten my hopes up by wishing for more...",1,
                                            "Have you met a Gym Leader named Shelly? I'm not sure if she's also around here, but we used to be close. I wish I could say the same about now...",
                                            "I haven't had a serious battle in a while... Maybe you can change that?",
                                            "I seem to have lost my fire after all..."]) if paged?("CAL")
        tournament_list.insert(insertIndex,[:CHAMPION_Leon,"Leon","I'm glad we've got such a strong trainer, but I don't plan on losing the next one!",
                                            "Thanks for always giving me the chance to have the greatest battles.",1,
                                            "Believe in yourself and your Pokémon! If you trust in one another and carry on battling side by side long enough, then someday you might even become worthy rivals for me, the unbeatable Champion!",
                                            "#{$Trainer.name}! I've been waiting for you. Always knew you'd be able to win your way here. Now, how about you take on Challenger Leon with everything that you've got?",
                                            "Your Pokémon certainly look delighted to battle alongside you, #{$Trainer.name}! But of course they do! They're lucky enough to battle with a trainer who knows just how to draw out the best of them! That's it. I'm gonna be sure to draw out even more of my own team members from now on, too!"]) if paged?("LEON")
        tournament_list.insert(insertIndex,[:LEADER_Amaria,"Amaria","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("AMARIA")
        tournament_list.insert(insertIndex,[:CHAMPION_Red,"Red","... ... ...",
                                            "...?!",1,
                                            ".................. ..................",
                                            "...",
                                            "... ...!"]) if paged?("RED")
        tournament_list.insert(insertIndex,[:ELITE_Agatha,"Agatha","Oh my! You're something special, child!",
                                            "Mark my words, I don't plan on ever retiring!",1,
                                            "How well can you handle Ghost-type Pokémon, child? They can sense a weak heart and will take advantage of it. You must always have a strong heart. Once you've grown closer to one, there's no longer anything to be afraid of.",
                                            "Let's get this started, shall we?",
                                            "You win! I see what everyone sees in you now. I have nothing else to say. Run along now, child!"]) if paged?("AGATHA")
        tournament_list.insert(insertIndex,[:LEADER_Lenora,"Lenora","Your fighting style is so enchanting. It is charming. I'm glad I met you!",
                                            "What's wrong? Could it be that you misread what moves I was going to use?",1,
                                            "Battling is second nature to you, isn't it? It's always best to be natural, no matter when it is and what kind of situation you're in. Your victory is the result of that, right?",
                                            "Well then, trainer, I'm going to research how you battle with the Pokémon you've so lovingly raised!",
                                            "You're impressive! And quite charming, aren't you?"]) if paged?("LENORA")
        tournament_list.insert(insertIndex,[:SKULL_Guzma,"Guzma","Tch! You kidding me?",
                                            "With power like this, I could... Eheheheheh.",1,
                                            "The hated boss who beats you down and beats you down and never lets up... Yeah. Big bad Guzma is here!",
                                            "Wanna see what destruction looks like? Here it is in human form-it's your boy Guzma!",
                                            "Guzma!!! What is wrong with you?!"]) if paged?("GUZMA")
        tournament_list.insert(insertIndex,[:FLARE_Lysandre,"Lysandre","Excellent! I can feel the fire of your convictions burning deep within your heart!",
                                            "Let's strive for a more beautiful world.",1,
                                            "People can be divided into two groups. Those who give... And those who take. I want to be the kind of person who gives.",
                                            "The future you want, or the future I want... Let us see which one is more deserving, shall we?",
                                            "Fools with no vision will continue to befoul this beautiful world. They will go on until the only thing left to do is squabble over the remaining scraps of hope..."]) if paged?("LYSANDRE")
        tournament_list.insert(insertIndex,[:TRAINER_Arclight,"Arclight","I won't forget the pain you just put my partner through!",
                                            "That was good enough! Cool!",1,
                                            "Hey, how are you? I'd like to find my rival here, you know. You must have rivals too; you're a trainer after all...",
                                            "Let's see how good of a trainer you are! I'll use my Pokémon with everything they've got!",
                                            "It can't be! How could I have lost? I need to apologize to my partner..."]) if paged?("ARCLIGHT")
        tournament_list.insert(insertIndex,[:LEADER_Titania,"Titania","Bravo! You showed me the spark of trainers. However, let me say just one thing... Please move on to an even greater goal!",
                                            "I'm winning this time, but you have talent! Your tactics... reading... You have great skills. That's right! I would like to battle you again and again!",1,
                                            "Don't mind me; I'm just one of the siblings who run the Battle Subway in Unova.",
                                            "Do you understand Pokémon well? Can you hold onto your principles? Will you go onto victory, or defeat? All aboard!",
                                            "Bravo! Excellent! I am glad that I fought so hard against a wonderful trainer like you. That's right! We grow stronger by matching ourselves against a strong opponent."]) if paged?("TITANIA")
        tournament_list.insert(insertIndex,[:METEOR_Solaris,"Solaris","NO! Jessie is going to kill me. Looks like Team Rocket's blasting off again!",
                                            "We were just getting to the good part!",1,
                                            "Huh, even Jessie and I were allowed in this tournament... They really accept everyone, even people like us, haha.",
                                            "Surrender now, or prepare to fight!",
                                            "I'm going to be blasted off, except this time by Jessie."]) if paged?("SOLARIS")
        tournament_list.insert(insertIndex,[:CHAMPION_Diantha,"Diantha","Witnessing the noble spirits of you and your Pokémon in battle has really touched my heart...",
                                            "Oh, fantastic! What did you think? My team is pretty cool, right? It's a bit embarrassing to show off, but I love to show their best sides!",1,
                                            "Oh my! I never thought I would meet you here! Honestly, I didn't! Oh, but silly me, I should at least do these things right...",
                                            "I've been hoping that I would see you again! Battling against you and your Pokémon, all of you brimming with hope for the future... Honestly, it just fills me up with energy I need to keep facing each new day! It does!",
                                            "I just...I just don't know what to say... I can hardly express this feeling... Battling you and your Pokémon makes everything seem worth it!"]) if paged?("DIANTHA")
        tournament_list.insert(insertIndex,[:CHAMPION_Iris,"Iris","The pain of my Pokémon... I feel it, too!",
                                            "We're stronger together!",1,
                                            "I'm so glad I came from Unova! There are many different people and so many different Pokémon there! And you know what... In the Village of Dragons, people take living alongside Pokémon for granted. I was surprised some people in Unova didn't think that way!",
                                            "The trainers who come here are trainers who desire victory with every fiber of their being! And they are battling alongside Pokémon that have been through countless difficult battles! If I battle with people like that, not only will I get stronger, my Pokémon will, too! And we'll get to know each other even better! Okay! Brace yourself! I'm Iris, and I'm going to defeat you!",
                                            "I'm upset I couldn't win! But you know what? More than that, I'm happy! I mean, come on. By having a serious battle, you and your Pokémon, and me and my Pokémon, we all got to know one another better than before! Yep, we sure did!"]) if paged?("IRIS")
        tournament_list.insert(insertIndex,[:LEADER_Maylene,"Maylene","I shall admit defeat.",
                                            "All our hard work paid off!",1,
                                            "Looking at the way you battle, I learned something! You like your Pokémon! I think it's wonderful!",
                                            "Whenever you're ready!",
                                            "I've still got some room to grow!"]) if paged?("MAYLENE")
        tournament_list.insert(insertIndex,[:LEADER_Wattson,"Wattson","Wahahahah! Alright, I lost! You gave me a thrill!",
                                            "Wahahahah! Well, I'm winning! Thrilling, right?",1,
                                            "Wahahahah! You're having some great victories! I'm so impressed by the way you battle that I can't help but laugh!",
                                            "You look like you have a lot of zip! That's a good thing. Wahahahaha! Then I, Wattson, shall electrify you with my Pokémon!",
                                            "Wahahahaha! I swell with optimism seeing a promising young trainer like you!"]) if paged?("WATTSON")
        tournament_list.insert(insertIndex,[:LEADER_Morty,"Morty","How is this possible...",
                                            "I moved...one step ahead again.",1,
                                            "I'm desperate to know the secret of your strength. If I unlock the secret, my dream to see the legendary Pokémon may come true! ...Excuse me. I got ahead of myself. Congratulations on your victories.",
                                            "Fighting against stronger foes is my training! You're going to help me reach the next level.",
                                            "I don't think our potentials are so different. But you seem to have something... Something more than that..."]) if paged?("MORTY")
        tournament_list.insert(insertIndex,[:CHAMPION_Cynthia,"Cynthia","When was the last time I was driven into a corner like this?",
                                            "The road before you is still very long, but never give up! You'll always have Pokémon at your side.",1,
                                            "I sincerely applaud your victory in the tournament. However, there are many other strong opponents in the world... I want to keep meeting many different people and Pokémon in other places as well.",
                                            "Before I send out my Pokémon, my heart always begins to race... Interesting... My Pokémon in their Poké Balls are radiating a happy feeling. Are you the reason?",
                                            "That was excellent. Truly, an outstanding battle. You gave the support your Pokémon needed to maximize their power. And you guided them with certainty to secure victory."]) if paged?("CYNTHIA")
        tournament_list.insert(insertIndex,[:LEADER_Korrina,"Korrina","Wh-what?! Not even my ultra-powerful team could stand up to you?!",
                                            "Yes! Don't you think we're the strongest?",1,
                                            "You know, I really want to prove to myself that I can be stronger. Since becoming a Gym Leader, I've been challenged to Pokémon battles by a ton of different trainers, but I want to be the one who makes the challenges again. I want to prove that my Pokémon and I can be number one.",
                                            "Time for Korrina's big appearance!",
                                            "Oh! I have been defeated! Alack, alay! Korrina gave a terrible display! This is it. I must give up my title and admit that your strength far exceeds- Just teasing!"]) if paged?("KORRINA")
        tournament_list.insert(insertIndex,[:LEADER_Candice,"Candice","You're mighty! You're worthy of lots of respect.",
                                            "I sensed your will to win, but I don't lose!",1,
                                            "You won because your focus was far greater than that of the others! Yes! I have to focus even more as well!",
                                            "You're the opponent of Candice? Sure thing! I was waiting for someone tough!",
                                            "Wow! You're great! You've earned my respect! I think your focus and will bowled us over totally. But next time I'll focus even more and won't lose!"]) if paged?("CANDICE")
        tournament_list.insert(insertIndex,[:LEADER_Bugsy,"Bugsy","Aw, that's the end of it...",
                                            "Thanks to our battle, I was also able to make progress in my research!",1,
                                            "\"I never lose when it comes to Bug-type Pokémon\", huh. I'm so embarrassed to have said that. I'll start my studies of other Pokémon over from the beginning, too.",
                                            "I never lose when it comes to Bug-type Pokémon. Let me demonstrate what I've learned from my studies.",
                                            "Whoa, amazing! You're an expert on Pokémon! My research isn't complete yet."]) if paged?("BUGSY")
        tournament_list.insert(insertIndex,[:ELITE_Will,"Will","I... I can't...believe it...",
                                            "Until we reach zero, our power is limitless!",1,
                                            "Your strength of mind-your strength of will-becomes your advantage in battle. Try it out sometime!",
                                            "I have trained all around the world, making my Psychic-type Pokémon powerful. I can only keep getting better! Losing is not an option!",
                                            "The way you relentlessly pursue victory, no matter who your opponent is or what obstacles appear in your path... There aren't many trainers out there who have your resolve."]) if paged?("WILL")
        tournament_list.insert(insertIndex,[:LEADER_Jasmine,"Jasmine","Oh, darn...",
                                            "Properly tempered steel won't be made rusty by things like this! If you keep training without giving up, I'm sure we'll see each other again.",1,
                                            "You are a better trainer than me, in both skill and kindness. Um... I don't know how to say this, but good luck...",
                                            "I use the... Clang! Steel type! ...Do you know about the Steel type? They are very cold, hard, sharp, and really strong! Um... I'm not lying.",
                                            "The blend of your kindness and your Pokémon's strength brought this victory to you. Um... Keep on doing your best... with your Pokémon."]) if paged?("JASMINE")
        tournament_list.insert(insertIndex,[:FRONTIER_Tucker,"Tucker","Grr... What the...",
                                            "Ahahaha! Aren't you embarrassed? Everyone's watching!",1,
                                            "Ah... The pummeling roar of the crowd... Their furnace-like heat of excitement... This is a wonderful place...",
                                            "Ahahah! Do you hear it? This crowd! They're all itching to see our match! Ahahah! I bet you're twitching all over from the tension of getting to battle me!",
                                            "... ... ... ... ... ... I sorely underestimate you. I won't make the same mistake next time..."]) if paged?("TUCKER")
        tournament_list.insert(insertIndex,[:ELITE_Phoebe,"Phoebe","Oh, darn. I've gone and lost.",
                                            "I was hoping that I would be able to become stronger here...",1,
                                            "I did my training on Mt. Pyre. While I trained there, I gained the ability to communicate with Ghost-type Pokémon; the bond I developed with my Pokémon is extremely tight.",
                                            "Ahahaha! I'm Phoebe of the Hoenn Elite Four. So, come on, just try and see if you can even inflict damage on my Pokémon!",
                                            "There's definitely a bond between you and your Pokémon, too. I didn't recognize that fact, so it's only natural that I lost. Yup, I'd like to see how far your bond will carry you."]) if paged?("PHOEBE")
        tournament_list.insert(insertIndex,[:MAGMA_Courtney,"Courtney","...Funny.",
                                            "...Slurp.",1,
                                            "I'm looking forward to... I'm looking forward to... When we...can meet again.",
                                            "...Ha.\m... ...Analyzing.\m...Hah.",
                                            "As anticipated. Unanticipated. You. Target lock...completed. Commencing...experiment. You. Forever. Aha..."]) if paged?("COURTNEY")
        tournament_list.insert(insertIndex,[:ELITE_Glacia,"Glacia","You and your Pokémon... How hot your spirits burn!",
                                            "What a relief it would be if I could, for once, have a serious battle.",1,
                                            "Have you ever been to the Hoenn region? It's a lovely place. The climate is warm, and it's full of beautiful, green nature. It's like a second home to me. I'd love to give you a tour someday.",
                                            "I wonder what you will show me...",
                                            "You and your Pokémon... How fiercely your spirits burn! My icy moves pale in the face of such all-consuming flames."]) if paged?("GLACIA")
        tournament_list.insert(insertIndex,[:ELITE_Drake,"Drake","Superb, it should be said.",
                                            "If you don't know what it truly takes for us to battle with Pokémon as partners, you will never prevail over me!",1,
                                            "Kids catching Pokémon are so adorable. I saw one recently that was so cute, I decided to say something. But that kid was scared of me and ran away. My old friend Briney has mentioned it from time to time, but do I really have such a scary face?",
                                            "My Pokémon and I are going to show you everything we've got! Well then, you had better get ready to try and stop me!",
                                            "You deserve every credit for coming this far as a Pokémon Trainer. You do seem to know what is needed. Yes, what a trainer needs is a true and virtuous heart. It is through their contact with trainers that Pokémon learn right from wrong. The influence of their trainers' good hearts helps them grow strong!"]) if paged?("DRAKE")
        tournament_list.insert(insertIndex,[:CHAMPION_Steven,"Steven","You are a truly noble Pokémon Trainer!",
                                            "When it comes down to it, I'm just the strongest there is right now.",1,
                                            "We all have a hidden glimmer within ourselves...a hidden excellence. When we're passionate about something or we're protecting something we care about, that glimmer inside us shines really bright...like the way the facets of a gemstone glint in the light.",
                                            "What has awoken in you because of your journey? I want you to hit me with it all! Now, bring it!",
                                            "Congratulations! The feelings you have for your Pokémon... And the Pokémon that responded to those feelings with all their might... They came together as one and created an even greater power. And thus, you were able to grasp victory!"]) if paged?("STEVEN")
        tournament_list.insert(insertIndex,[:TRAINER_Benga,"Benga","I knew it! That trainer smelled tough!",
                                            "We can keep aiming higher, as Pokémon Trainers and as people! And it's all thanks to our Pokémon! Come again! I want to keep aiming higher!",1,
                                            "In the arena. There we'll see who's stronger! Let's try hard to be the best!",
                                            "You and us! Our Pokémon! The strength we have! We'll give it our all! No holding back!",
                                            "So exciting! You and your Pokémon's combination! Amazing teamwork!"]) if paged?("BENGA")
        tournament_list.insert(insertIndex,[:CHATELAINE_Evelyn,"Evelyn","Hah... Hah... You're so strong... And so scary... I can't take any more...",
                                            "I'm s-s-so sorry! I didn't m-mean for anything like this to... It wasn't supposed to happen like this! Oh no... *Sniffle* *Sob*... I'm so sorry...",1,
                                            "Uh-umm, hi... Th-the weather is in a lovely way today, isn't it?",
                                            "I'll t-try t-t-to serve you as a Battle Chatelaine like my sisters, so... Please s-start the battle already!",
                                            "Um, fair play! You were so very strong! Th-the truth is I was nervous facing strangers. So I don't know what I did... B-but I will try even harder the next time!"]) if paged?("EVELYN")
        tournament_list.insert(insertIndex,[:TRAINER_Zinnia,"Zinnia","I guess I could use a little more excitement...",
                                            "Niiice! Real nice!",1,
                                            "I'm just a traveling Pokémon Trainer, dreaming of taking a little trip into space... Heh.",
                                            "Give me a good taste of everything you and your Pokémon have to offer!",
                                            "...I guess...it falls to you now... That settles it, then..."]) if paged?("ZINNIA")
        tournament_list.insert(insertIndex,[:TRAINER_Wally,"Wally","I'm definitely going to get stronger. Much, much, stronger.",
                                            "We'll keep pushing past our limits, you'll see!",1,
                                            "Hi! #{$Trainer.name}! I bet you're surprised to see me here! I made it all the way here, and it's all thanks to you! #{$Trainer.name}, losing to you that time made me stronger! But I'm not going to lose anymore! I'm going to win! For the Pokémon who gave me courage and strength!",
                                            "Get ready... Here I come!",
                                            "I've lost..."]) if paged?("WALLY")
        tournament_list.insert(insertIndex,[:ELITE_Caitlin,"Caitlin","I can't believe it's come to this! I must have gotten complacent.",
                                            "Winning is important, but what's more important is whether or not I've outdone myself.",1,
                                            "When I battled you, I couldn't help but smile... Because I was able to improve myself, and because you were an excellent trainer. I want to improve and win more elegantly, so I invite you to be my opponent again in the future, if you wish.",
                                            "Hmf... You still appear to possess a combination of strength and kindness. Very well. Make your best effort not to bore me with a yawn-inducing battle. Clear?",
                                            "You and your Pokémon are both excellent and elegant. To have been able to battle against such a splendid team... My Pokémon and I learned a lot! I offer you my thanks."]) if paged?("CAITLIN")
        tournament_list.insert(insertIndex,[:LEADER_Flannery,"Flannery","Oh... I guess I was trying too hard...",
                                            "My Pokémon were able to make the most of their power when I did things my way!",1,
                                            "Your strength is the way you're able to express yourself. Everybody was very excited by your victory!",
                                            "I'm going to demonstrate the hot moves I honed close to a volcano!",
                                            "Your strength sure reminds me of someone... You must have battled with many different people and learned good things from them every time, huh?"]) if paged?("FLANNERY")
        tournament_list.insert(insertIndex,[:LEADER_Noel,"Noel","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("NOEL")
        tournament_list.insert(insertIndex,[:METEOR_Blake,"Blake","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("BLAKE")
        tournament_list.insert(insertIndex,[:RIVAL_Claudia,"Claudia","I knew I shouldn't have endeavored such a meaningless thing...",
                                            "I knew I could only count on Pokémon to make me smile again...",1,
                                            "*Sigh* You again? As long as you leave me alone...",
                                            "The bond I've developed with my Pokémon is the only thing that gets me going...",
                                            "Life is nothing more than a cycle of pain, so why do we bother trying to reach happiness..."]) if paged?("CLAUDIA")
        tournament_list.insert(insertIndex,[:TRAINER_Sigmund,"Sigmund Connal","NO! Jessie is going to kill me. Looks like Team Rocket's blasting off again!",
                                            "We were just getting to the good part!",1,
                                            "Huh, even Jessie and I were allowed in this tournament... They really accept everyone, even people like us, haha.",
                                            "Surrender now, or prepare to fight!",
                                            "I'm going to be blasted off, except this time by Jessie."]) if paged?("SIGMUNDCONNAL")
        tournament_list.insert(insertIndex,[:KAHUNA_Hapu,"Hapu","Thud! That's the sound of your strength rocking me to my core!",
                                            "I am training to properly form my desire for victory.",1,
                                            "My own venerable grandfather is the only one I had to emulate growing up, so I am not familiar with your hip, groovy slang. \"Hip\" and \"groovy\" are modern slang words...right? Well, either way, I have gotten used to saying them now, and that's not likely to change.",
                                            "Do you want to try to take me and my Pokémon on at our full strength?",
                                            "I look forward to our next battle."]) if paged?("HAPU")
        tournament_list.insert(insertIndex,[:CHATELAINE_Nita,"Nita","En't you a jammie one!",
                                            "Would you look at the cut of me Pokémon! What a battle, and me not trying for real even!",1,
                                            "I may be the youngest of us four Battle Chatelaine sisters, but I'm still a class trainer. I've been an owner of the Battle Maison this long while, I'm not telling fibs!",
                                            "Hello-how-are-ya? Are ya in good form? Would you do me a favor? Of a bit of a match? You will? Grand! Then let's begin at once!",
                                            "Wahey! That was such great fun!"]) if paged?("NITA")
        tournament_list.insert(insertIndex,[:LEADER_Clemont,"Clemont","Your passion for battle inspires me!",
                                            "Looks like my Trainer-Grow-Stronger Machine, Mach 2 is really working!",1,
                                            "Whew, I could sure use a bite to eat right now... Maybe I should invent a machine that can replicate food instantaneously!",
                                            "Oh! I'm glad that we got to meet yet again like this!",
                                            "I'm glad whenever I get to learn from other strong challengers. Thank you for the battle!"]) if paged?("CLEMONT")
        tournament_list.insert(insertIndex,[:ELITE_Flint,"Flint","...! I don't believe it! I'd never even considered it! I'm blown away by this! You and your Pokémon are hot stuff!",
                                            "This situation... This is heating up! I'm blazing now!",1,
                                            "Sometimes people say that as a member of the Sinnoh Elite Four, I should dress more properly. But see, this is my style! I told them, if you're going to change your whole style just 'cause someone told you to, that's not very proper as a trainer, you know? Of course, the day after I said that, I went and burned my foot on Infernape's fire. Turns out wearing flip-flops has drawbacks. If someone gives you some advice, you should at least listen!",
                                            "This situation just cooks! The drama and tension sizzles! Flint, the fiery master of Fire Pokémon, is going to put you to the test! Let Flint see how hot your spirit burns!",
                                            "...Whew... Burnt right down to cinders... Keep going... I know your spirit burns hot. Your whole team does."]) if paged?("FLINT")
        tournament_list.insert(insertIndex,[:LEADER_Ramos,"Ramos","A true friendship with Pokémon takes time. Yeh can't force it, yeh little whippersnapper!",
                                            "Hohoho... Indeed. Frail little blades o' grass'll break through even concrete.",1,
                                            "Ho ho! The best things in life take time, sprout! Yeh've got to learn not to be so hasty, especially at suppertime!",
                                            "So here I am, whippersnapper! I'm sure I'll enjoy a Pokémon battle with yeh, sprout, sure as trees grow up!",
                                            "Yeh believe in yer Pokémon... And they believe in yeh, too... It was a fine battle, sprout."]) if paged?("RAMOS")
        tournament_list.insert(insertIndex,[:LEADER_Amber,"Amber","Ugh! You're such a twerp! Looks like Team Rocket's blasting off again...",
                                            "What?! Did we just win? I... I didn't think that was possible! James, get the camera!",1,
                                            "Next time it's going to be the perfect time to show Team Rocket's potential, just watch!",
                                            "Prepare for trouble!",
                                            "Well, Team Rocket failed again... Should I be surprised?"]) if paged?("AMBER")
        tournament_list.insert(insertIndex,[:ELITE_Acerola,"Acerola","Well, there goes my hope of beating you to smithereens and becoming the winner myself!",
                                            "*Giggle* We're in full swing now!",1,
                                            "I love reading! You can find a book about pretty much anything, you know. Books can take us on journeys to fantastical worlds and tell the stories of people far away from us!",
                                            "Hiya! I'm here to bring an old royal touch to this tournament!",
                                            "I'm...I'm speechless! You've done me in!"]) if paged?("ACEROLA")
        tournament_list.insert(insertIndex,[:ELITE_Drasna,"Drasna","Oh, dear me...",
                                            "How can this be?",1,
                                            "Oh goodness, hello to you! You know, my grandparents came to Kalos from a distant region. They came from a town where the past lives on... When I was growing up at their knees, they raised me on tales of the Pokémon of time and space. It's really thanks to those stories that I decided to become a Dragon-type trainer.",
                                            "Oh, goodness, hello to you! I'm so glad you've joined us! I know that you're very strong. That will make this great fun!",
                                            "Oh, you! You're too much! You and your Pokémon are simply charming!"]) if paged?("DRASNA")
        tournament_list.insert(insertIndex,[:CAPTAIN_Ilima,"Ilima","You are positively shining! Yes, it's important to always shine.",
                                            "I just had the perfect strategy, but you should keep doing your best!",1,
                                            "It's not battle results that interest me. Rather, it's the carefully-thought-out strategies or novel tactics employed by trainers. How those plans affect one's opponent and influence the outcome of battles, that is where my interest lies!",
                                            "In a sense, this is a trial. A trial to see whose battle strategy will succeed!",
                                            "Yes! You have emerged victorious!"]) if paged?("ILIMA")
        tournament_list.insert(insertIndex,[:FRONTIER_Anabel,"Anabel","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("ANABEL")
        tournament_list.insert(insertIndex,[:LEADER_Gardenia,"Gardenia","Aww, really? My Grass-type Pokémon are growing good and strong, too...",
                                            "Yes! My Pokémon and I are perfectly good!",1,
                                            "Amazing! Hey! How do you feel? I want to win and brag about my Pokémon, too!",
                                            "Let's cut to the good stuff! Let's get down to battle!",
                                            "You're really tough! Wasn't it hard for you to raise your Pokémon to be so good? I guess that's a measure of how much you love your Pokémon."]) if paged?("GARDENIA")
        tournament_list.insert(insertIndex,[:TRAINER_Bennett,"Bennett","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("BENNETT")
        tournament_list.insert(insertIndex,[:TRAINER_Buck,"Buck","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("BUCK")
        tournament_list.insert(insertIndex,[:LEADER_Melony,"Melony","I think you took breaking the ice a little too literally...",
                                            "Looks like someone needs to chill.",1,
                                            "I won't be putting on a showy battle for the crowd. I'll show everyone what a severe battle truly is.",
                                            "I suppose we should get started. You won't be able to escape when I freeze you solid. And after that... Well, you'll see. I think you'll find my battle style is quite severe.",
                                            "I just want to climb into a hole... Well, I guess it'd be more like falling from here, right?"]) if paged?("MELONY")
        tournament_list.insert(insertIndex,[:LEADER_Roxie,"Roxie","Wild! Your reason's already more toxic than mine!",
                                            "Hey, c'mon! Get serious! You gotta put more out there!",1,
                                            "Congrats on your win! Losing stinks, but still... You're a fun Pokémon Trainer to battle! I mean, c'mon! The Pokémon battling with you are all like, \"We're gonna win!\"",
                                            "Get ready! I'm gonna knock some sense outta ya!",
                                            "Wait! I was right in the middle of the chorus!"]) if paged?("ROXIE")
        tournament_list.insert(insertIndex,[:FRONTIER_Darach,"Darach","My Pokémon could not be faulted in any way or form. My hat's off to you.",
                                            "Lady Caitlin, my employer, is not one to accept defeat willingly. I am the same.",1,
                                            "Excellent battling, #{$Trainer.name}. I could tell that you give it your absolute best. Well done indeed!",
                                            "Your mastery of Pokémon is as breathtaking as ever. #{$Trainer.name}, you certainly are to be commended. ...However, let me assure you that you won't be shortchanged by facing me. En garde!",
                                            "#{$Trainer.name}, you are truly in possession of a superlative talent! I drew on every reserve of experience and etiquette handed down through our heritage of glorious servitude. But even then, I failed To fend off your inspired and inspiring challenge."]) if paged?("DARACH")
        tournament_list.insert(insertIndex,[:ELITE_Malva,"Malva","You have secured a noble victory over me!",
                                            "I am delighted! Yes, delighted that I could squash you beneath my heel.",1,
                                            "Oooh, you filthy brat! You're just too much, you know? You're so amusing that I just want to burn you up where you stand! But I'll let you live.... After all... If you want your dreams to come true, you have to be strong enough to force them to happen. Team Flare wasn't strong enough to do that, but I can see that you are.",
                                            "Oh, I can't tell you how happy I am to meet you again... I feel like my heart might just burst into flames. I'm burning up with my hatred for you, runt!",
                                            "Oooh, you wicked little trainer, you! I will definitely remember this battle!"]) if paged?("MALVA")
        tournament_list.insert(insertIndex,[:FRONTIER_Noland,"Noland","Good job! You know what you're doing!",
                                            "Way to work! That was a good lesson, eh?",1,
                                            "I'm the Frontier Brain that tests your knowledge. I know it's hard to imagine with me lookin' like this. But knowledge ain't just somethin' you get by studyin'. In order to experience everything, you need to have a honed mind and body to handle it!",
                                            "Hey, hey! How's it going? You keeping up with your studies? This should be fun! I'm getting excited, hey! All right! Bring it on!",
                                            "Smart going! Heh... You're a pretty bright spark... Next time, I'll come after you hard. No holds barred, understand? You keep up your studies!"]) if paged?("NOLAND")
        tournament_list.insert(insertIndex,[:LEADER_Raihan,"Raihan","Ho? Not bad!",
                                            "In the aftermath of the furious battle... I feel as pure and refreshed as when the sky clears after a storm.",1,
                                            "I'm going to win my way through every round, then I'll be the one taking on Leon! If I don't, then I'll have failed to repay Duraludon and the rest of my team for all their hard work!",
                                            "I'm going to defeat everyone, win the whole tournament, and prove to the world just how strong the great Raihan really is!",
                                            "I might have lost, but I still look good. Maybe I should snap a quick selfie..."]) if paged?("RAIHAN")
        tournament_list.insert(insertIndex,[:LEADER_Piers,"Piers","I don't do encores, get it? Not songs... Not moves... Not Pokémon!",
                                            "We're the greatest combo of all-time!",1,
                                            "Do you sing or play any instruments, #{$Trainer.name}? I'm curious. I bet you'd probably make some rockin' music. If you ever do write a song, let me hear it.",
                                            "Get ready for a mosh pit with me and my party! It's time to rock!",
                                            "Me an' my team gave it our best. Let's meet up again for a battle some time..."]) if paged?("PIERS")
        tournament_list.insert(insertIndex,[:LEADER_Kabu,"Kabu","I would certainly like to live up to your expectations.",
                                            "Flame always burns upwards, and so we'll always aim to go higher. You understand, don't you?",1,
                                            "Every trainer and Pokémon trains hard in pursuit of victory. But that means your opponent is also working hard to win. In the end, the match is decided by which side is able to unleash their true potential.",
                                            "A tournament that ends when you lose! Whoever can keep up the heat will win here!",
                                            "Great Pokémon and a great trainer! It's no surprise that you won!"]) if paged?("KABU")
        tournament_list.insert(insertIndex,[:RIVAL_Bede,"Bede","Why did I have the misfortune of being born in the same time period as you...?",
                                            "We've shown you a truly great pink!",1,
                                            "Hrmph...",
                                            "I suppose I should prove beyond doubt just how pathetic you are and how strong I am.",
                                            "I couldn't win, but at least I was able to show everyone how great Fairy-types are."]) if paged?("BEDE")
        tournament_list.insert(insertIndex,[:ELITE_Wikstrom,"Wikstrom","Glorious! The trust that you share with your honorable Pokémon surpasses even mine!",
                                            "Winning against such a worthy opponent doth give my soul wings, thus do I soar!",1,
                                            "Maintaining the glorious condition of my steel armor requires intensive training. Some days, I plunge my steel gloves into an open flame. On others, I seat myself beneath a raging waterfall.",
                                            "Well met, young challenger! Verily am I the famed blade of hardened steel, Wikstrom! Let the battle begin! En garde!",
                                            "What manner of disaster be this? My heart, it doth hammer ceaselessly in my breast! At last do I understand that sweet torture, that perfect balance of joy and frustration!"]) if paged?("WIKSTROM")
        tournament_list.insert(insertIndex,[:TRAINER_Eusine,"Eusine","I hate to admit it, but you win.",
                                            "All right! Everyone, were you watching us?",1,
                                            "I'm on the trail of a Pokémon named Suicune. I have a feeling I won't be seeing it around here though...",
                                            "I'll battle you as a trainer to earn the public's respect! Come on, #{$Trainer.name}! Let's battle now!",
                                            "You're amazing, #{$Trainer.name}! No wonder Pokémon gravitate to you."]) if paged?("EUSINE")
        tournament_list.insert(insertIndex,[:AQUA_Archie,"Archie","Oh! You went and did it, didn't you?",
                                            "Ah, fine... You're still too young.",1,
                                            "So tell me, #{$Trainer.name}... Do you know that Pokémon, people, and all life in this world depend on the sea for life? That's right. The sea is an irreplaceable treasure for every living thing on this planet. But with our selfish extravagance, humanity dirties the great ocean, destroying this source of all life... Day by day, we're all destroying our most precious resource! If we humans suffer from our actions, well, maybe we'll end up getting what we deserve.",
                                            "Well then, you little scamp... It's the rope's end for you and your Pokémon!",
                                            "Well, would you look at that! I control the ocean and all its power, and yet here I am, beaten by a little tyke! All right, all right... You've made your point."]) if paged?("ARCHIE")
        tournament_list.insert(insertIndex,[:MAGMA_Maxie,"Maxie","I fell behind, but only by an inch...",
                                            "Just as I expected.",1,
                                            "Oh, you're still wandering around here?",
                                            "I can't allow an ignorant child like you to get in our way. I, Maxie, will show you the consequences of meddling!",
                                            "You've really done it, child. You've shown a power that exceeds that of the great Maxie!"]) if paged?("MAXIE")
        tournament_list.insert(insertIndex,[:LEADER_Adrienn,"Adrienn","I'm glad we've got such a strong trainer, but I don't plan on losing the next one!",
                                            "Thanks for always giving me the chance to have the greatest battles.",1,
                                            "Believe in yourself and your Pokémon! If you trust in one another and carry on battling side by side long enough, then someday you might even become worthy rivals for me, the unbeatable Champion!",
                                            "#{$Trainer.name}! I've been waiting for you. Always knew you'd be able to win your way here. Now, how about you take on Challenger Leon with everything that you've got?",
                                            "Your Pokémon certainly look delighted to battle alongside you, #{$Trainer.name}! But of course they do! They're lucky enough to battle with a trainer who knows just how to draw out the best of them! That's it. I'm gonna be sure to draw out even more of my own team members from now on, too!"]) if paged?("ADRIENN")
        tournament_list.insert(insertIndex,[:RIVAL_Aelita,"Aelita","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("AELITA")
        tournament_list.insert(insertIndex,[:CHAMPION_Alder,"Alder","You certainly are an unmatched talent!",
                                            "That was an extraordinary effort from both you and your Pokémon!",1,
                                            "That was an impressive battle! The spirit of my first partner, Larvesta - no, Volcarona - lives on in my current partners, too! I want to add your strength to their experience as well!",
                                            "I show everyone how wonderful it is to move forward together with Pokémon. Competing like this is probably the best way to show everyone!",
                                            "Well done! The ones who change the world are always the ones who pursue their dreams. That's right! They're just like you."]) if paged?("ALDER")
        tournament_list.insert(insertIndex,[:TRAINER_AZ,"AZ","Now I finally feel free...",
                                            "Do you want to know unending pain...like I have?",1,
                                            "The Pokémon... The flower Pokémon... The Pokémon that was given eternal life...",
                                            "Battle with me. I want to know what a \"trainer\" is.",
                                            "Thank you very much for battling with me."]) if paged?("AZ")
        tournament_list.insert(insertIndex,[:ELITE_Bertha,"Bertha","You're quite something, youngster.",
                                            "Dear child, never assume for an instant that you have won before it's over.",1,
                                            "I like how you and your Pokémon earned the winnings by working as one. That's what makes you so strong. Ahahaha! I think that you can go as far as you want.",
                                            "Well, well. You're quite the adorable trainer, but you've also got a spine. Well, would you show this old lady how much you've learned?",
                                            "Well! Dear child, I must say, that was most impressive. Your Pokémon believed in you and did their best to earn you the win. Even though I've lost, I find myself with this silly grin!"]) if paged?("BERTHA")
        tournament_list.insert(insertIndex,[:FRONTIER_Brandon,"Brandon","That's it! You've done great! You've worked hard for this!",
                                            "Hey! What's wrong with you! Let's see some effort! Get up!",1,
                                            "Young adventurer... Wouldn't you agree that explorations are the grandest of adventures? Your own wits! Your own strength! Your own Pokémon! And, above all, only your courage to lead you through unknown worlds...",
                                            "Aah, yes, indeed this life is grand! Grand, it is! You coming here means you have that much confidence in yourself, am I right? Hahahah! This should be exciting! Now, then! Bring your courage to our battle!",
                                            "Hahahah! Remarkable! Yes, it's grand, indeed! Young explorer! You've bested me through and through!"]) if paged?("BRANDON")
        tournament_list.insert(insertIndex,[:LEADER_Brycen,"Brycen","The wonderful combination of you and your Pokémon! What a beautiful friendship!",
                                            "Extreme conditions really test you and train you!",1,
                                            "A tournament is a story, too... And the stars of this story were you and your Pokémon.",
                                            "There is also strength in being with other people and Pokémon. Receiving their support makes you stronger. I'll show you this power!",
                                            "You are strong! No, both you and your Pokémon are strong!"]) if paged?("BRYCEN")
        tournament_list.insert(insertIndex,[:FLARE_Bryony,"Bryony","Oh my, oh my?",
                                            "Forget it. I should've never wasted my time with you.",1,
                                            "Your ability flies in the face of all probability. Just what is the source of your power?",
                                            "Have you calculated the chance of your victory? No? Well I have, and I can say it's not looking too bright for you...",
                                            "Probability is just probability, after all... Absolutes do not exist."]) if paged?("BRYONY")
        tournament_list.insert(insertIndex,[:ELITE_Aaron,"Aaron","I will now concede defeat. But I think you came to see how great Bug-type Pokémon can be.",
                                            "Do you see now? The greatness of Bug-type Pokémon!",1,
                                            "I'm a huge fan of Bug Pokémon. Bug Pokémon are nasty-mean, and yet they're beautiful, too...",
                                            "Would you like to know why I enjoy battling so much? It's because I want to become perfect, just like my Bug Pokémon! Okay! Let me take you on!",
                                            "Battling is a deep and complex affair..."]) if paged?("AARON")
        tournament_list.insert(insertIndex,[:RIVAL_Cain,"Cain","Yep. Well, that's that~",
                                            "I mean, I have talent for this~",1,
                                            "I'm not really sure how I got here, but it's been incredible. Y'know, you remind me of my rival from Reborn, they're really something else.",
                                            "Well, well, well. Let's see what you got!",
                                            "Cute AND talented~"]) if paged?("CAIN")
        tournament_list.insert(insertIndex,[:RIVAL_Bianca,"Bianca","Phew! You're really a strong trainer, that's for sure!",
                                            "The Pokémon on both sides tried sooo hard, didn't they?",1,
                                            "Even if it's just little by little, I'm learning about Pokémon. I'm thinking about how to bring out the best from everyone, but I still have a ways to go. Oh, I almost forgot! Congratulations on your victory!",
                                            "A Pokémon battle with you! I feel really excited!",
                                            "Thank you for being my opponent! Yep! I learned a lot! Know what? Recently, I've been thinking Pokémon stay by our sides to bring people together... I'm thinking of researching that!"]) if paged?("BIANCA")
        tournament_list.insert(insertIndex,[:LEADER_Charlotte,"Charlotte","The pain of my Pokémon... I feel it, too!",
                                            "We're stronger together!",1,
                                            "I'm so glad I came from Unova! There are many different people and so many different Pokémon there! And you know what... In the Village of Dragons, people take living alongside Pokémon for granted. I was surprised some people in Unova didn't think that way!",
                                            "The trainers who come here are trainers who desire victory with every fiber of their being! And they are battling alongside Pokémon that have been through countless difficult battles! If I battle with people like that, not only will I get stronger, my Pokémon will, too! And we'll get to know each other even better! Okay! Brace yourself! I'm Iris, and I'm going to defeat you!",
                                            "I'm upset I couldn't win! But you know what? More than that, I'm happy! I mean, come on. By having a serious battle, you and your Pokémon, and me and my Pokémon, we all got to know one another better than before! Yep, we sure did!"]) if paged?("CHARLOTTE")
        tournament_list.insert(insertIndex,[:LEADER_Cheren,"Cheren","Fantastic! You and your Pokémon have grown much stronger!",
                                            "Even when you lose, your Pokémon are still brimming with fighting spirit.",1,
                                            "I learned something from this battle... But only a little. What does it mean to be strong...? What are Pokémon...? There are so many things I don't know!",
                                            "Even if hurt, my Pokémon will fight for me with just one command. I think I'll value and trust your Pokémon more if you keep that fact close to your heart. What can I do for these Pokémon? What should I do? That's right! I battle with everything to find the ideal relationship between Pokémon and people!",
                                            "I made it where I am because Pokémon were by my side. Perhaps we need to think about why Pokémon help us not in terms of Pokémon and trainers but as a relationship between living beings."]) if paged?("CHEREN")
        tournament_list.insert(insertIndex,[:LEADER_Ciel,"Ciel","Wahahahah! Alright, I lost! You gave me a thrill!",
                                            "Wahahahah! Well, I'm winning! Thrilling, right?",1,
                                            "Wahahahah! You're having some great victories! I'm so impressed by the way you battle that I can't help but laugh!",
                                            "You look like you have a lot of zip! That's a good thing. Wahahahaha! Then I, Wattson, shall electrify you with my Pokémon!",
                                            "Wahahahaha! I swell with optimism seeing a promising young trainer like you!"]) if paged?("CIEL")
        tournament_list.insert(insertIndex,[:GALACTIC_Cyrus,"Cyrus","Impressive. Your prowess is notable.",
                                            "How foolish...",1,
                                            "I can sense in you the strong desire to protect...something. You have a powerful spirit...",
                                            "I must remove the weak, incomplete human spirit from this world and bring it perfection! I will not let you get in my way...",
                                            "Interesting. And quite curious."]) if paged?("CYRUS")
        tournament_list.insert(insertIndex,[:FRONTIER_Dahlia,"Dahlia","You're so very, very good! My Pokémon had a good time, too!",
                                            "I believe luck is on my side today!~",1,
                                            "Whenever I battle someone tough, I smile. I cannot help it! How about you? What do you do? Do you laugh? Cry? Get angry?",
                                            "No need to worry. Let chance do what it does. Like surprises from the game board, life goes through twists and turns. No need to worry. Things will go as they will. But, enough of that. I know one thing for certain. You have arrived here not merely because you were lucky. Let us not waste any time. I wish to test your skills myself!",
                                            "Battling a wonderful trainer is always a happy occasion!"]) if paged?("DAHLIA")
        tournament_list.insert(insertIndex,[:LEADER_Clair,"Clair","It's over...",
                                            "Come on! You've got to get tougher than this!",1,
                                            "Oh, hi. How are you doing? Lately there seems to be some gossip running through town that I am the latest name in fashion. Well, if I'm that cool that people can't stop talking about me, I can totally understand that sentiment.",
                                            "I am the world's best Dragon-type master. I will use my full power against any opponent!",
                                            "I lost? I don't believe it. There must be some mistake..."]) if paged?("CLAIR")
        tournament_list.insert(insertIndex,[:TRAINER_Elias,"Elias","You're mighty! You're worthy of lots of respect.",
                                            "I sensed your will to win, but I don't lose!",1,
                                            "You won because your focus was far greater than that of the others! Yes! I have to focus even more as well!",
                                            "You're the opponent of Candice? Sure thing! I was waiting for someone tough!",
                                            "Wow! You're great! You've earned my respect! I think your focus and will bowled us over totally. But next time I'll focus even more and won't lose!"]) if paged?("EL")
        tournament_list.insert(insertIndex,[:LEADER_Elesa,"Elesa","I meant to make your head spin, but you shocked me instead.",
                                            "That was unsatisfying somehow... Will you give it your all next time?",1,
                                            "My Pokémon work hard for me, so I want to do what I can for them. And I want them to bathe in the glamorous spotlight as well. In that sense, your Pokémon were gleaming very brightly!",
                                            "The stage is ours. Watch out, our dazzling brilliance might just blind you!",
                                            "My, oh my... You have a sweet fighting style."]) if paged?("ELESA")
        tournament_list.insert(insertIndex,[:SUBWAYBOSS_Emmet,"Emmet","You're a verrrrry strong trainer! Yup! It was fun!",
                                            "I am Emmet. We won, but I am not really satisfied. I can tell that you won't give up. Because you will be much, much stronger. That's why we are waiting for you to come back!",1,
                                            "I am Emmet. I am a Subway Boss. I like Double Battles. I like combinations of two Pokémon. And I like winning more than anything else.",
                                            "What I do. What I say. Always the same. Follow the rules. Safe driving! Follow the schedules. Everyone smile! Check safety. Everything's ready! Aim for victory! All aboard!",
                                            "I am Emmet. I lost against you. Because you are the strongest trainer I've fought lately."]) if paged?("EMMET")
        tournament_list.insert(insertIndex,[:RIVAL_Erin,"Erin","Ohhh! No one enjoys losing, but you all were such great opponents!",
                                            "The photo from the moment of my victory will be a real winner. Alright!",1,
                                            "Even in another region, I'm always looking for the perfect shot. Very interesting, right?",
                                            "That determined expression... That glint in your eye that says you're up for challenges... It's fantastic! Now come at me! My lens is always focused on victory - I won't let anything ruin this shot!",
                                            "You and your Pokémon have shown me a whole new depth of field! Fantastic! Just fantastic!"]) if paged?("ERIN")
        tournament_list.insert(insertIndex,[:TRAINER_Ethan,"Ethan","Ngh...",
                                            "I can handle any obstacle, as long as I've got my Pokémon with me.",1,
                                            "Isn't it strange that when we are with Pokémon, going out is just so much more fun! #{$Trainer.name}! Try going to different places and talk to your Pokémon! I bet you'll find out so many things about them!",
                                            "Let's do this!",
                                            "Haha! Don't worry."]) if paged?("ETHAN")
        tournament_list.insert(insertIndex,[:RIVAL_Barry,"Barry","Oh, darn. I've gone and lost.",
                                            "I was hoping that I would be able to become stronger here...",1,
                                            "I did my training on Mt. Pyre. While I trained there, I gained the ability to communicate with Ghost-type Pokémon; the bond I developed with my Pokémon is extremely tight.",
                                            "Ahahaha! I'm Phoebe of the Hoenn Elite Four. So, come on, just try and see if you can even inflict damage on my Pokémon!",
                                            "There's definitely a bond between you and your Pokémon, too. I didn't recognize that fact, so it's only natural that I lost. Yup, I'd like to see how far your bond will carry you."]) if paged?("BARRY")
        tournament_list.insert(insertIndex,[:XEN_Geara,"Geara","...Funny.",
                                            "...Slurp.",1,
                                            "I'm looking forward to... I'm looking forward to... When we...can meet again.",
                                            "...Ha.\m... ...Analyzing.\m...Hah.",
                                            "As anticipated. Unanticipated. You. Target lock...completed. Commencing...experiment. You. Forever. Aha..."]) if paged?("GEARA")
        tournament_list.insert(insertIndex,[:PLASMA_Ghetsis,"Ghetsis","What's this?! This is nothing like I expected!",
                                            "I'm absolutely perfect! I AM PERFECTION! I am the perfect ruler of a perfect new world!",1,
                                            "I'm sure you believe that we humans and Pokémon are partners that have come to live together because we want and need each other. However... Is that really the truth? Have you ever considered that perhaps we humans... only assume that this is the truth? Pokémon are subject to the selfish commands of trainers... They get pushed around when they are our "partners" at work... Can you say with confidence that there is no truth in what I'm saying?",
                                            "All obstacles to my ambitions must be removed!",
                                            "I couldn't have been defeated by some random trainer from who knows where!"]) if paged?("GHETSIS")
        tournament_list.insert(insertIndex,[:ELITE_Bruno,"Bruno","Fight as hard as you can 'til you faint!",
                                            "We're standing firm!",1,
                                            "I always train to the extreme because I believe in our potential. That is how we became strong.",
                                            "Can you withstand our power? Hm? I see no fear in you. You look determined. Perfect for battle! Ready, #{$Trainer.name}? You will bow down to our overwhelming power! Hoo hah!",
                                            "Why?! ...How could we lose?"]) if paged?("BRUNO")
        tournament_list.insert(insertIndex,[:LEADER_Grant,"Grant","You're a wall that I am unable to surmount!",
                                            "Do not give up. That is all there really is to it. The most important lessons in life are simple.",1,
                                            "I wonder how I happened to find my selfish Tyrunt in the same place I found my sweet Amaura... Maybe our friendship goes above and beyond the walls of our differences.",
                                            "There is only one thing I wish for. That by surpassing one another, we find a way to even greater heights.",
                                            "Yes, this is the way it should be. This way both humans and Pokémon will grow."]) if paged?("GRANT")
        tournament_list.insert(insertIndex,[:FRONTIER_Greta,"Greta","No way! Good job!",
                                            "Oh, come on! You have to try harder than that!",1,
                                            "If we ever battle again, I won't lose! Don't you forget it!",
                                            "Hey! Howdy! ...Wait, are you my next opponent? Is this right? Hmm... Hmhm... Are you sure you're up for me? Hmm... Well, all right! We'll take things easy to start with! Okay! Let's see you ignite my passion for battle!",
                                            "Ow, wait a second! You are tough after all! I like you!"]) if paged?("GRETA")
        tournament_list.insert(insertIndex,[:LEADER_Crawli,"Crawli","Hah... Hah... You're so strong... And so scary... I can't take any more...",
                                            "I'm s-s-so sorry! I didn't m-mean for anything like this to... It wasn't supposed to happen like this! Oh no... *Sniffle* *Sob*... I'm so sorry...",1,
                                            "Uh-umm, hi... Th-the weather is in a lovely way today, isn't it?",
                                            "I'll t-try t-t-to serve you as a Battle Chatelaine like my sisters, so... Please s-start the battle already!",
                                            "Um, fair play! You were so very strong! Th-the truth is I was nervous facing strangers. So I don't know what I did... B-but I will try even harder the next time!"]) if paged?("CRAWLI")
        tournament_list.insert(insertIndex,[:LEADER_Drayden,"Drayden","This intense feeling that floods me after a defeat... I don't know how to describe it.",
                                            "Harrumph! I know your ability is greater than that!",1,
                                            "I may be old, but I desire victory! This desire is the energy for life! It's the power to surpass who I was the previous day! I compliment you on your victory, but next time, victory will be mine!",
                                            "What I want to find is a young trainer who can show me a bright future. Let's battle with everything we have: your skill, my experience, and the love with which we've raised our Pokémon!",
                                            "Wonderful. I'm grateful we had a chance to meet and battle. Make a bright future-not just for yourself, but for others as well."]) if paged?("DRAYDEN")
        tournament_list.insert(insertIndex,[:LEADER_Hardy,"Hardy","I'm definitely going to get stronger. Much, much, stronger.",
                                            "We'll keep pushing past our limits, you'll see!",1,
                                            "Hi! #{$Trainer.name}! I bet you're surprised to see me here! I made it all the way here, and it's all thanks to you! #{$Trainer.name}, losing to you that time made me stronger! But I'm not going to lose anymore! I'm going to win! For the Pokémon who gave me courage and strength!",
                                            "Get ready... Here I come!",
                                            "I've lost..."]) if paged?("HARDY")
        tournament_list.insert(insertIndex,[:RIVAL_Hau,"Hau","Nice! How'd you come up with that kind of battle plan? You gotta tell me!",
                                            "As long as we both have a good time, then I think we can call it a great battle, eh?",1,
                                            "You know, whenever I feel cramped, I go out on adventures. I feel that I can become a new me when I breathe some fresh air.",
                                            "All right! Let's go full powered on this one!",
                                            "Aww, man! I wanted to show off the best side of my Pokémon!"]) if paged?("HAU")
        tournament_list.insert(insertIndex,[:RIVAL_Huey,"Huey","Oh... I guess I was trying too hard...",
                                            "My Pokémon were able to make the most of their power when I did things my way!",1,
                                            "Your strength is the way you're able to express yourself. Everybody was very excited by your victory!",
                                            "I'm going to demonstrate the hot moves I honed close to a volcano!",
                                            "Your strength sure reminds me of someone... You must have battled with many different people and learned good things from them every time, huh?"]) if paged?("HUEY")
        tournament_list.insert(insertIndex,[:LEADER_Janine,"Janine","Not good. Seriously not good.",
                                            "I'm Janine! Remember this name!",1,
                                            "Everybody in the Fuchsia City Gym disguises themselves to look like me! You can imagine how hard it is to find me! It's really fun, and a lot of the challengers have good things to say about it, but...nobody realizes it's me if I ever dress up.",
                                            "I'm the real deal! I'll show you what it means to be a ninja master!",
                                            "...!!! So... So strong!"]) if paged?("JANINE")
        tournament_list.insert(insertIndex,[:LEADER_Byron,"Byron","Hmm! My sturdy Pokémon, defeated!",
                                            "Gwahahaha! How were my sturdy Pokémon?!",1,
                                            "Guhahahaha! I lost, but I saw something great. Well, guess I'll go back to Sinnoh and start my son's training over! All right! Next time I take part in the tournament, I'll play to win!",
                                            "Trainer! You're young, just like my son, Roark. With more young trainers taking charge, the future of Pokémon is bright! So, as a wall for young people, I'll take your challenge!",
                                            "Gwahahaha! You were strong enough to take down my prized team of Pokémon. I recognize your power. Please show your power to other trainers, too!"]) if paged?("BYRON")
        tournament_list.insert(insertIndex,[:LEADER_Juan,"Juan","Ahahaha, excellent! Very well, you are the winner.",
                                            "Ahahaha, I'm the winner! Which is to say, you lost.",1,
                                            "I see! Your elegance radiates glitz and glamor. It's only natural that you're winning the tournaments.",
                                            "Please, you shall bear witness to our artistry. A grand illusion of water sculpted by Pokémon and myself!",
                                            "From you, I sense the brilliant shine of skill that will overcome all! However, you are somewhat lacking in elegance. Perhaps I should make you a loan of my outfit? ...Hahaha, I merely jest!"]) if paged?("JUAN")
        tournament_list.insert(insertIndex,[:GALACTIC_Jupiter,"Jupiter","How insolent.",
                                            "Oh? Are you finished already? Your Pokémon aren't bad, but you're laughably weak.",1,
                                            "Oh? Don't I know you? Listen. Don't come whining about poor Pokémon and other trivial junk like that. Now, if you'll excuse me...",
                                            "Take a bite of this, child!",
                                            "Losing to some child... Being careless cost me my dignity."]) if paged?("JUPITER")
        tournament_list.insert(insertIndex,[:FRONTIER_Argenta,"Argenta","Well! My goodness, your Pokémon... They've got star power beyond belief.",
                                            "Oh... I detest how fun times seem to end so quickly.",1,
                                            "A good trainer doesn't force their favorite Pokémon on anyone. A good one keeps with their favorite without drama or fanfare. That is how I see it, at least.",
                                            "I must see for myself if that brilliance I sense from your Pokémon is genuine. That is why we must battle now.",
                                            "You must never forget there is a place where everyone can shine. That goes for any kind of Pokémon, too. Spread that message in your own words. It's one everyone should hear. And now, having lost, this lady has nothing left to say at all, but... Bye-bye!"]) if paged?("ARGENTA")
        tournament_list.insert(insertIndex,[:LEADER_Clay,"Clay","Well, I've had enough... And just so you know, I didn't go easy on you.",
                                            "It's simple, hear! I wanted to win more than ya did!",1,
                                            "#{$Trainer.name}! Yer finally showin' some true grit, ain't ya. But I reckon you've still got some room to grow in those britches o' yers. Aim for the sky, I always say! If y'all can face yer opponent head on 'n' win -no cheap tricks- I reckon y'all have got some real skill!",
                                            "If ya want ta win, don't make excuses! Got it? If yer gonna bellyache, just forget 'bout fightin'! Well, I might be fussin' 'bout nothing when it comes to you.",
                                            "Fer such a young 'un, ya have an imposin' battle style. I wonder what kind a journey ya had that made ya so strong. But, I still don't like losin'!"]) if paged?("CLAY")
        tournament_list.insert(insertIndex,[:ELITE_Kahili,"Kahili","Bravo! You showed me the spark of trainers. However, let me say just one thing... Please move on to an even greater goal!",
                                            "I'm winning this time, but you have talent! Your tactics... reading... You have great skills. That's right! I would like to battle you again and again!",1,
                                            "Don't mind me; I'm just one of the siblings who run the Battle Subway in Unova.",
                                            "Do you understand Pokémon well? Can you hold onto your principles? Will you go onto victory, or defeat? All aboard!",
                                            "Bravo! Excellent! I am glad that I fought so hard against a wonderful trainer like you. That's right! We grow stronger by matching ourselves against a strong opponent."]) if paged?("KAHILI")
        tournament_list.insert(insertIndex,[:ELITE_Karen,"Karen","Well, aren't you good. I like that in a trainer.",
                                            "This is far from being backed into a corner!",1,
                                            "It's kind of hard to put into words what it is about Dark-type Pokémon that fascinates me so... They're so wild and adorable... *sigh* Words just don't do them justice!",
                                            "I'm Karen, of the Indigo Elite Four. I hope you can at least provide me a bit of entertainment.",
                                            "Strong Pokémon. Weak Pokémon. That is only the selfish perception of people. Truly skilled trainers should try to win with the Pokémon they love best. I like your style. You understand what's important."]) if paged?("KAREN_GS")
        tournament_list.insert(insertIndex,[:TRAINER_Karrina,"Karrina","Witnessing the noble spirits of you and your Pokémon in battle has really touched my heart...",
                                            "Oh, fantastic! What did you think? My team is pretty cool, right? It's a bit embarrassing to show off, but I love to show their best sides!",1,
                                            "Oh my! I never thought I would meet you here! Honestly, I didn't! Oh, but silly me, I should at least do these things right...",
                                            "I've been hoping that I would see you again! Battling against you and your Pokémon, all of you brimming with hope for the future... Honestly, it just fills me up with energy I need to keep facing each new day! It does!",
                                            "I just...I just don't know what to say... I can hardly express this feeling... Battling you and your Pokémon makes everything seem worth it!"]) if paged?("KARRINA")
        tournament_list.insert(insertIndex,[:CAPTAIN_Kiawe,"Kiawe","The pain of my Pokémon... I feel it, too!",
                                            "We're stronger together!",1,
                                            "I'm so glad I came from Unova! There are many different people and so many different Pokémon there! And you know what... In the Village of Dragons, people take living alongside Pokémon for granted. I was surprised some people in Unova didn't think that way!",
                                            "The trainers who come here are trainers who desire victory with every fiber of their being! And they are battling alongside Pokémon that have been through countless difficult battles! If I battle with people like that, not only will I get stronger, my Pokémon will, too! And we'll get to know each other even better! Okay! Brace yourself! I'm Iris, and I'm going to defeat you!",
                                            "I'm upset I couldn't win! But you know what? More than that, I'm happy! I mean, come on. By having a serious battle, you and your Pokémon, and me and my Pokémon, we all got to know one another better than before! Yep, we sure did!"]) if paged?("KIAWE")
        tournament_list.insert(insertIndex,[:ROCKET_Ariana,"Ariana","This can't be happening! I fought hard, but I still lost...",
                                            "Ahahahaha, you? Defeat me? Ahahaha, that's so laughable!",1,
                                            "You're good. Why don't you join Team Rocket?",
                                            "I'm so sorry, baby, but get ready to be thrashed.",
                                            "Feh... People like you will never in a million years understand our brilliance! It's too bad..."]) if paged?("ARIANA")
        tournament_list.insert(insertIndex,[:CAPTAIN_Lana,"Lana","Wahahahah! Alright, I lost! You gave me a thrill!",
                                            "Wahahahah! Well, I'm winning! Thrilling, right?",1,
                                            "Wahahahah! You're having some great victories! I'm so impressed by the way you battle that I can't help but laugh!",
                                            "You look like you have a lot of zip! That's a good thing. Wahahahaha! Then I, Wattson, shall electrify you with my Pokémon!",
                                            "Wahahahaha! I swell with optimism seeing a promising young trainer like you!"]) if paged?("LANA")
        tournament_list.insert(insertIndex,[:RIVAL_Lillie,"Lillie","How is this possible...",
                                            "I moved...one step ahead again.",1,
                                            "I'm desperate to know the secret of your strength. If I unlock the secret, my dream to see the legendary Pokémon may come true! ...Excuse me. I got ahead of myself. Congratulations on your victories.",
                                            "Fighting against stronger foes is my training! You're going to help me reach the next level.",
                                            "I don't think our potentials are so different. But you seem to have something... Something more than that..."]) if paged?("LILLIE")
        tournament_list.insert(insertIndex,[:ELITE_Grimsley,"Grimsley","The winner takes everything, and there's nothing left for the loser.",
                                            "If somebody wins, the person who fought against that person will lose.",1,
                                            "I hope someday you, too, will discover a Pokémon that draws your gaze with its beauty and charm in battle. When you do, I have a feeling you'll develop a new thirst for victory within you as well.",
                                            "Life is a serious battle, and you have to use the tools you're given. It's more important to master the cards you're holding than to complain about the ones your opponents were dealt. Let us begin. And may the best trainer win! Contests like this are proof that you are really living...",
                                            "When one loses, they lose everything... The next thing I'll look for will be victory, too!"]) if paged?("GRIMSLEY")
        tournament_list.insert(insertIndex,[:AETHER_Lusamine,"Lusamine","You're mighty! You're worthy of lots of respect.",
                                            "I sensed your will to win, but I don't lose!",1,
                                            "You won because your focus was far greater than that of the others! Yes! I have to focus even more as well!",
                                            "You're the opponent of Candice? Sure thing! I was waiting for someone tough!",
                                            "Wow! You're great! You've earned my respect! I think your focus and will bowled us over totally. But next time I'll focus even more and won't lose!"]) if paged?("LUSAMINE")
        tournament_list.insert(insertIndex,[:TRAINER_Lyra,"Lyra","We tried our best!",
                                            "Woo-hoo! We're looking good!",1,
                                            "I knew it was you, #{$Trainer.name}! How did you get past me?",
                                            "We won't go easy on you!",
                                            "Parties and Pokémon battles share a couple things in common: the most important of which is you gotta have fun!"]) if paged?("LYRA")
        tournament_list.insert(insertIndex,[:LEADER_Wake,"Wake","Hunwah! It's gone and ended! How will I say this... I want more! I wanted to battle a lot more!",
                                            "I won, but I want more! I wanted to battle a lot more!",1,
                                            "Battling with you was fun! I hope your victory will put more smiles on people's faces!",
                                            "My Pokémon were toughened up by stormy white waters! They'll take everything you can throw at them and then pull you under! Victory will be ours! Come on, let's get it done!",
                                            "The styles of battling and winning are as widely varied as trainers are. Do you want to know how I battle? I battle so I can say I had fun at the end, whether I win or lose!"]) if paged?("WAKE")
        tournament_list.insert(insertIndex,[:XEN_Madelis,"Madelis","Oh, darn...",
                                            "Properly tempered steel won't be made rusty by things like this! If you keep training without giving up, I'm sure we'll see each other again.",1,
                                            "You are a better trainer than me, in both skill and kindness. Um... I don't know how to say this, but good luck...",
                                            "I use the... Clang! Steel type! ...Do you know about the Steel type? They are very cold, hard, sharp, and really strong! Um... I'm not lying.",
                                            "The blend of your kindness and your Pokémon's strength brought this victory to you. Um... Keep on doing your best... with your Pokémon."]) if paged?("MADELIS")
        tournament_list.insert(insertIndex,[:TRAINER_Marley,"Marley","...My time with you is drawing to a close.",
                                            "Wow. This makes me happy.",1,
                                            "If a trainer doesn't give good commands, Pokémon get hurt in battle… That's why I want to get better at battling. And it was fun for me and my Pokémon when we battled with you.",
                                            "...So? ...Are we going to battle, or what?",
                                            "...You're so strong. It makes me feel happy. ...I don't know why. This is a strange feeling..."]) if paged?("MARLEY")
        tournament_list.insert(insertIndex,[:LEADER_Marlon,"Marlon","You're strong as a gnarly wave and as nice as a glassy sea.",
                                            "You're tough, but it's not enough to sway the sea, 'K!",1,
                                            "This one time back in the day, I was feelin' totally wiped out after a Pokémon battle... Carracosta was all outta whack, too, so we decided to bail out on a trip we were plannin' on takin' with a friend. When our friend got back from the trip, he told us about all the fun stuff we missed out on... I realized in hindsight that I shoulda gone on that trip anyway, even if I was tired. Ever since that day, I've been tellin' myself to dive headfirst into anything that seems fun!",
                                            "I'm strong like the ocean's wide. You're gonna get swept away, fo' sho'. Eh, that's enough talk! I'll prove it! Let's get started, 'K?",
                                            "You don't just look strong--you're strong fo' reals! Eh, I was swept away, too!"]) if paged?("MARLON")
        tournament_list.insert(insertIndex,[:GALACTIC_Mars,"Mars","This can't be?! I'm losing?! You... you uppity brat!",
                                            "Haha, of course I am winning!",1,
                                            "I'm one of Team Galactic's three Commanders. We've been trying to create a new world that's better than this one... But people have shown little understanding about what we do. You don't understand either, do you? It's a little saddening...",
                                            "What's with that look on your face? You do remember me, don't you? Fine, whatever. I'll tell you who I am again! I'm Mars, one of Team Galactic's Commanders, and you're going down!",
                                            "Oops! I messed that one up! That's all right, though. I quite enjoyed our battle."]) if paged?("MARS")
        tournament_list.insert(insertIndex,[:ELITE_Marshal,"Marshal","Whew! Well done! As your battles continue, aim for even greater heights!",
                                            "Oh, so strong. That makes my heart dance!",1,
                                            "You are a strong challenger. Walk the path you believe in with the Pokémon you believe in. Other trainers here are more powerful than I am. Do not underestimate them!",
                                            "Greetings, challenger. My name is Marshal. It is my intention to test you--to take you to the limits of your strength. Kiai!",
                                            "There is no single strongest Pokémon or sole best combination... That's why it is difficult to keep winning. However, I think a heart that desires strength and strives to grow stronger is a precious ideal. That is why I respect you--because you have these things."]) if paged?("MARSHAL")
        tournament_list.insert(insertIndex,[:CHAMPION_Kukui,"Kukui","Superb, it should be said.",
                                            "If you don't know what it truly takes for us to battle with Pokémon as partners, you will never prevail over me!",1,
                                            "Kids catching Pokémon are so adorable. I saw one recently that was so cute, I decided to say something. But that kid was scared of me and ran away. My old friend Briney has mentioned it from time to time, but do I really have such a scary face?",
                                            "My Pokémon and I are going to show you everything we've got! Well then, you had better get ready to try and stop me!",
                                            "You deserve every credit for coming this far as a Pokémon Trainer. You do seem to know what is needed. Yes, what a trainer needs is a true and virtuous heart. It is through their contact with trainers that Pokémon learn right from wrong. The influence of their trainers' good hearts helps them grow strong!"]) if paged?("KUKUI")
        tournament_list.insert(insertIndex,[:AQUA_Matt,"Matt","Oho! That hurt just about exactly as much as I figured!",
                                            "Hooaahhh! You clown!",1,
                                            "Hehehe! So you've come all the way here! Just wait until you face Archie...",
                                            "...Hoo! ...Haaahh! I'm... Heating up! Me! You! Pokémon! Mixing it up! Dueling! Hooah! Full on! I'm burning up! Well! Welll! Wellllll! Let's battle it out until we've got nothing left!",
                                            "That was fun! I knew you'd show me a good time! I look forward to facing you again someday!"]) if paged?("MATT")
        tournament_list.insert(insertIndex,[:RIVAL_Melia,"Melia","I knew it! That trainer smelled tough!",
                                            "We can keep aiming higher, as Pokémon Trainers and as people! And it's all thanks to our Pokémon! Come again! I want to keep aiming higher!",1,
                                            "In the arena. There we'll see who's stronger! Let's try hard to be the best!",
                                            "You and us! Our Pokémon! The strength we have! We'll give it our all! No holding back!",
                                            "So exciting! You and your Pokémon's combination! Amazing teamwork!"]) if paged?("MELIA")
        tournament_list.insert(insertIndex,[:ELITE_Lucian,"Lucian","I see. You getting here was no fluke. Your power is real.",
                                            "Hmm... Now what should I do...",1,
                                            "...Ah, hello. I was just reading a collection of observations on Pokémon in the wild. One article addresses the question why Pokémon would go into a Poké Ball. According to this article, this behavior is based on instinct. A weakened Pokémon will curl up tight in an effort to heal itself. The Poké Ball was invented to take advantage of that protective instinct. I imagine we'll see each other again in the Pokémon World Tournament. Take care.",
                                            "They say I am the toughest of the Sinnoh Elite Four. I'm afraid I will have to go all out against you to live up to that reputation.",
                                            "I'll be reading books until my next battle. That will calm my nerves, so that I may deal with all situations without panicking."]) if paged?("LUCIAN")
        tournament_list.insert(insertIndex,[:LEADER_Cress,"Cress","Lose? Me? I don't believe this.",
                                            "This is the appropriate result when I'm your opponent.",1,
                                            "The pairings for the tournament partly contributed to your victory. Please keep training. I plan on retraining myself with the aim of defeating you after you've become even stronger.",
                                            "That is correct! It is I, Cress, Water-type enthusiast, whom you must face in battle!",
                                            "How amazing! Even if there were a lot of reasons, you managed to defeat someone as impressive as me!"]) if paged?("CRESS")
        tournament_list.insert(insertIndex,[:TRAINER_N,"N","You've got to value this time that you have to get to know each other!",
                                            "For the sake of my friend who saved me, I will never give up!",1,
                                            "When I was little, I was separated from other humans and raised by Pokémon. That's why I wanted to liberate them from being confined in Poké Balls. It was all for the sake of Pokémon--my friends.",
                                            "Your Pokémon are saying they want to battle with my friend... Will you give me this honor?",
                                            "Your Pokémon are happy... They are happy to be with you."]) if paged?("N")
        tournament_list.insert(insertIndex,[:LEADER_Fantina,"Fantina","Oh, heavens. What is this? How am I losing?",
                                            "You are strong. But it's me who won.",1,
                                            "I'm so very happy! Because you're so very strong! There's so much I can learn from you. I can become even stronger. When I do, let's battle again!",
                                            "I learned a lot of things in the Sinnoh region. Also, I study Pokémon very much. I have come to be a Gym Leader. And, uh, so it shall be that you challenge me. But I shall win. That is what the Gym Leader of Hearthome does, non?",
                                            "You are so fantastically strong. I know now why I have lost."]) if paged?("FANTINA")
        tournament_list.insert(insertIndex,[:LEADER_Narcissa,"Narcissa","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("NARCISSA")
        tournament_list.insert(insertIndex,[:LEADER_Liza,"Liza","I still gotta get stronger!",
                                            "Awesome. I can feel power flowing through me!",1,
                                            "My Solrock has been full of energy ever since we came here. Can you feel it? That crackling, popping sensation? You can tell how your Pokémon is feeling, even without any special powers!",
                                            "Thanks to my strict training, I can make myself one with Pokémon! Can you beat this combination and the bond between me and my Pokémon?",
                                            "How could we lose?"]) if paged?("LIZA")
        tournament_list.insert(insertIndex,[:LEADER_Norman,"Norman","I... I can't... I can't believe it.",
                                            "We both gave everything we have. This was a wonderful match.",1,
                                            "You went all out and earned that victory... You're a wonderful trainer! I want my kid to learn from you.",
                                            "I lost to my own child... I rethought everything about myself, so now there is no way I can lose! I'll do everything in my power to win! You'd better give it your best shot, too!",
                                            "I'm going to redouble my training by taking on this tournament! It would bother me as a trainer to not avenge my loss to you!"]) if paged?("NORMAN")
        tournament_list.insert(insertIndex,[:LEADER_Olympia,"Olympia","Farewell...",
                                            "Winner and loser. A winged Pokémon leads on, to the goal of both.",1,
                                            "With your Pokémon. Countless stars light your way forth. You have no limits.",
                                            "A ritual to decide your fate and future. The battle begins!",
                                            "Create your own path. Let nothing get in your way. Your fate, your future."]) if paged?("OLYMPIA")
        tournament_list.insert(insertIndex,[:FRONTIER_Palmer,"Palmer","I have no problem losing to a spectacular trainer like you!",
                                            "Ah, wonderful! This is fantastic!",1,
                                            "You know, it's hard to be the strongest trainer in the tournament, but when you're fighting against really good trainers, you can feel that it's all worth it.",
                                            "I heard a lot about you. You are #{$Trainer.name}, right? You are much younger than I thought. So, I'd like you to show me. Show me the bond you've built with your Pokémon. Show me what you've learned through battles with trainers!",
                                            "Bravo! I feel inspired in my heart! My young friend, the world and your future hold infinite promise. The spirits of people and Pokémon call for each other in resonance. The resulting bond is finitely strong! Go on, you can be all that you desire! There is no limit to where you can go!"]) if paged?("PALMER")
        tournament_list.insert(insertIndex,[:KAHUNA_Nanu,"Nanu","Thud! That's the sound of your strength rocking me to my core!",
                                            "I am training to properly form my desire for victory.",1,
                                            "My own venerable grandfather is the only one I had to emulate growing up, so I am not familiar with your hip, groovy slang. \"Hip\" and \"groovy\" are modern slang words...right? Well, either way, I have gotten used to saying them now, and that's not likely to change.",
                                            "Do you want to try to take me and my Pokémon on at our full strength?",
                                            "I look forward to our next battle."]) if paged?("NANU")
        tournament_list.insert(insertIndex,[:LEADER_Pryce,"Pryce","Hmm. Seems as if my luck has run out.",
                                            "This is winter's harshness.",1,
                                            "If it's someone like you, I'm sure you'll keep winning and will find something important. Keep it up.",
                                            "I have seen and suffered much in my life. Since I am your elder, let me show you what I mean.",
                                            "I am impressed by your prowess. With your strong will, I know you will overcome all life's obstacles."]) if paged?("PRYCE")
        tournament_list.insert(insertIndex,[:LEADER_Radomus,"Radomus","Your passion for battle inspires me!",
                                            "Looks like my Trainer-Grow-Stronger Machine, Mach 2 is really working!",1,
                                            "Whew, I could sure use a bite to eat right now... Maybe I should invent a machine that can replicate food instantaneously!",
                                            "Oh! I'm glad that we got to meet yet again like this!",
                                            "I'm glad whenever I get to learn from other strong challengers. Thank you for the battle!"]) if paged?("RADOMUS")
        tournament_list.insert(insertIndex,[:RIVAL_Reina,"Reina","A true friendship with Pokémon takes time. Yeh can't force it, yeh little whippersnapper!",
                                            "Hohoho... Indeed. Frail little blades o' grass'll break through even concrete.",1,
                                            "Ho ho! The best things in life take time, sprout! Yeh've got to learn not to be so hasty, especially at suppertime!",
                                            "So here I am, whippersnapper! I'm sure I'll enjoy a Pokémon battle with yeh, sprout, sure as trees grow up!",
                                            "Yeh believe in yer Pokémon... And they believe in yeh, too... It was a fine battle, sprout."]) if paged?("REINA")
        tournament_list.insert(insertIndex,[:RIVAL_Ren,"Ren","Ugh! You're such a twerp! Looks like Team Rocket's blasting off again...",
                                            "What?! Did we just win? I... I didn't think that was possible! James, get the camera!",1,
                                            "Next time it's going to be the perfect time to show Team Rocket's potential, just watch!",
                                            "Prepare for trouble!",
                                            "Well, Team Rocket failed again... Should I be surprised?"]) if paged?("REN")
        tournament_list.insert(insertIndex,[:TRAINER_Riley,"Riley","Well, there goes my hope of beating you to smithereens and becoming the winner myself!",
                                            "*Giggle* We're in full swing now!",1,
                                            "I love reading! You can find a book about pretty much anything, you know. Books can take us on journeys to fantastical worlds and tell the stories of people far away from us!",
                                            "Hiya! I'm here to bring an old royal touch to this tournament!",
                                            "I'm...I'm speechless! You've done me in!"]) if paged?("RILEY")
        tournament_list.insert(insertIndex,[:TRAINER_Risa,"Risa Raider","Oh, dear me...",
                                            "How can this be?",1,
                                            "Oh goodness, hello to you! You know, my grandparents came to Kalos from a distant region. They came from a town where the past lives on... When I was growing up at their knees, they raised me on tales of the Pokémon of time and space. It's really thanks to those stories that I decided to become a Dragon-type trainer.",
                                            "Oh, goodness, hello to you! I'm so glad you've joined us! I know that you're very strong. That will make this great fun!",
                                            "Oh, you! You're too much! You and your Pokémon are simply charming!"]) if paged?("RISA")
        tournament_list.insert(insertIndex,[:TRAINER_Rood,"Rood","You are positively shining! Yes, it's important to always shine.",
                                            "I just had the perfect strategy, but you should keep doing your best!",1,
                                            "It's not battle results that interest me. Rather, it's the carefully-thought-out strategies or novel tactics employed by trainers. How those plans affect one's opponent and influence the outcome of battles, that is where my interest lies!",
                                            "In a sense, this is a trial. A trial to see whose battle strategy will succeed!",
                                            "Yes! You have emerged victorious!"]) if paged?("ROOD")
        tournament_list.insert(insertIndex,[:LEADER_Roxanne,"Roxanne","So... I lost... It seems that I still have much more to learn...",
                                            "I learned many things from our battle.",1,
                                            "I learned many things from our battle."
    Lobby Speech: "You were flawless. You're a role model for trainers. The way you battle makes it hard to put it any other way. I can understand why you won! I want to learn even more about you!",
                                            "I apply what I learned at the Pokémon Trainer's School in battle. Would you kindly demonstrate how you battle and with which Pokémon?",
                                            "It seems that I still have much more to learn... I will participate in the tournament again. Will you be my opponent then as well?"]) if paged?("ROXANNE")
        tournament_list.insert(insertIndex,[:TRAINER_Ryuki,"Ryuki","Aww, really? My Grass-type Pokémon are growing good and strong, too...",
                                            "Yes! My Pokémon and I are perfectly good!",1,
                                            "Amazing! Hey! How do you feel? I want to win and brag about my Pokémon, too!",
                                            "Let's cut to the good stuff! Let's get down to battle!",
                                            "You're really tough! Wasn't it hard for you to raise your Pokémon to be so good? I guess that's a measure of how much you love your Pokémon."]) if paged?("RYUKI")
        tournament_list.insert(insertIndex,[:LEADER_Samson,"Samson","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("SAMSON_R")
        tournament_list.insert(insertIndex,[:LEADER_Saphira,"Saphira","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("SAPHIRA")
        tournament_list.insert(insertIndex,[:GALACTIC_Saturn,"Saturn","I think you took breaking the ice a little too literally...",
                                            "Looks like someone needs to chill.",1,
                                            "I won't be putting on a showy battle for the crowd. I'll show everyone what a severe battle truly is.",
                                            "I suppose we should get started. You won't be able to escape when I freeze you solid. And after that... Well, you'll see. I think you'll find my battle style is quite severe.",
                                            "I just want to climb into a hole... Well, I guess it'd be more like falling from here, right?"]) if paged?("SATURN")
        tournament_list.insert(insertIndex,[:TRAINER_Serena,"Serena","We did our best...",
                                            "Eeheehee, we were just getting started!",1,
                                            "You were so strong! I could feel how powerful the bond between you and your partner is. Losing is frustrating, but... I'm really happy for you!",
                                            "You and your Pokémon are stronger... I can tell just by looking at you. But I will not lose. No... I'm going to win!",
                                            "So, I lost, then..."]) if paged?("SERENA")
        tournament_list.insert(insertIndex,[:LEADER_Serra,"Serra","My Pokémon could not be faulted in any way or form. My hat's off to you.",
                                            "Lady Caitlin, my employer, is not one to accept defeat willingly. I am the same.",1,
                                            "Excellent battling, #{$Trainer.name}. I could tell that you give it your absolute best. Well done indeed!",
                                            "Your mastery of Pokémon is as breathtaking as ever. #{$Trainer.name}, you certainly are to be commended. ...However, let me assure you that you won't be shortchanged by facing me. En garde!",
                                            "#{$Trainer.name}, you are truly in possession of a superlative talent! I drew on every reserve of experience and etiquette handed down through our heritage of glorious servitude. But even then, I failed To fend off your inspired and inspiring challenge."]) if paged?("SERRA")
        tournament_list.insert(insertIndex,[:ELITE_Shauntal,"Shauntal","My Pokémon and the challenger's Pokémon. Everyone battled even though they were hurt... Thank you.",
                                            "Wow, all this potential! I'm at a loss for words!",1,
                                            "Even with a wealth of vocabulary, some feelings simply can't be put into words. Perhaps that's a topic I should challenge myself with as a writer. Yes! Someday I'll capture these indescribable emotions with my pen and share them with the world!",
                                            "I'm Shauntal, a Ghost-type Pokémon Trainer. I am both a writer and a member of the Unova Elite Four, and now I shall be your opponent.",
                                            "Do you ever feel at a loss for words when something greatly moves you? To tell the truth... I'm a writer, but right now I'm having trouble putting my feelings into words. You were just that impressive!"]) if paged?("SHAUNTAL")
        tournament_list.insert(insertIndex,[:LEADER_Shelly,"Shelly","Good job! You know what you're doing!",
                                            "Way to work! That was a good lesson, eh?",1,
                                            "I'm the Frontier Brain that tests your knowledge. I know it's hard to imagine with me lookin' like this. But knowledge ain't just somethin' you get by studyin'. In order to experience everything, you need to have a honed mind and body to handle it!",
                                            "Hey, hey! How's it going? You keeping up with your studies? This should be fun! I'm getting excited, hey! All right! Bring it on!",
                                            "Smart going! Heh... You're a pretty bright spark... Next time, I'll come after you hard. No holds barred, understand? You keep up your studies!"]) if paged?("SHELLY_R")
        tournament_list.insert(insertIndex,[:AQUA_Shelly,"Shelly","Ooohhhh! Are you telling me you're that strong and still just a kid?!",
                                            "Hah, see? That's the power of Team Aqua!",1,
                                            "Wanna know something? I'm feeling so empty and downhearted right now. I can't get my head straight. Umm? Ah, forget it. I'll figure it out...",
                                            "Prepare yourself! I'll leave that cute face of yours swollen and crying!",
                                            "Ahhh?! Did I go too easy on you?!"]) if paged?("SHELLY_S")
        tournament_list.insert(insertIndex,[:ELITE_Sidney,"Sidney","Well, how do you like that? I lost! Eh, it was fun, so it doesn't matter.",
                                            "Heheh, we're gettin' good.",1,
                                            "Oh! It's you! You're still here, too, huh? I guess when trainers find out about a facility like this, it gets their blood pumping. This place reeks of hard-driving trainers.",
                                            "I like that look you're giving me. I guess you'll give me a good match. That's good! Looking real good! All right! Let's get down to this!",
                                            "Well, listen to what this loser has to say. You've got what it takes to go a long way!"]) if paged?("SIDNEY")
        tournament_list.insert(insertIndex,[:ELITE_Siebold,"Siebold","... ... ... No, I simply can't accept this.",
                                            "Our Pokémon battle was like food for my soul. It shall keep me going. That is how I will pay my respects to you for giving your all in battle!",1,
                                            "Devote yourself entirely, so even that which will fade and disappear is ingrained forever upon your heart and mind! That is the only fate for any human.",
                                            "... ... ... Yes, I see it now. This is a path with no end. To seek to be the absolute best is an absurd goal. Yet, as long as I am alive, I shall strive onward to seek the ultimate cuisine... and the strongest opponents in battle!",
                                            "I shall store my memory of you and your Pokémon forever away within my heart."]) if paged?("SIEBOLD")
        tournament_list.insert(insertIndex,[:METEOR_Sirius,"Sirius","Why did I have the misfortune of being born in the same time period as you...?",
                                            "We've shown you a truly great pink!",1,
                                            "Hrmph...",
                                            "I suppose I should prove beyond doubt just how pathetic you are and how strong I am.",
                                            "I couldn't win, but at least I was able to show everyone how great Fairy-types are."]) if paged?("SIRIUS")
        tournament_list.insert(insertIndex,[:LEADER_Skyla,"Skyla","Being your opponent in battle is a new source of strength to me. Thank you!",
                                            "Win or lose, you always gain something from a battle, right?",1,
                                            "Are you and your Pokémon well? Our battle together was so much fun. Now, my Pokémon and I have started training again. I don't usually let people travel in my cargo plane, but battling with you was such a blast that I'd make an exception.",
                                            "What I like is having fun! I love doing things like flying in the sky with Pokémon and bringing out their best! So, how about you and I have some fun?",
                                            "You're a pretty amazing Pokémon Trainer, aren't you? My Pokémon and I are happy, because for the first time in a while, we could fight with our full strength."]) if paged?("SKYLA")
        tournament_list.insert(insertIndex,[:LEADER_Luna,"Luna","I hate to admit it, but you win.",
                                            "All right! Everyone, were you watching us?",1,
                                            "I'm on the trail of a Pokémon named Suicune. I have a feeling I won't be seeing it around here though...",
                                            "I'll battle you as a trainer to earn the public's respect! Come on, #{$Trainer.name}! Let's battle now!",
                                            "You're amazing, #{$Trainer.name}! No wonder Pokémon gravitate to you."]) if paged?("LUNA")
        tournament_list.insert(insertIndex,[:CAPTAIN_Sophocles,"Sophocles","Oh! You went and did it, didn't you?",
                                            "Ah, fine... You're still too young.",1,
                                            "So tell me, #{$Trainer.name}... Do you know that Pokémon, people, and all life in this world depend on the sea for life? That's right. The sea is an irreplaceable treasure for every living thing on this planet. But with our selfish extravagance, humanity dirties the great ocean, destroying this source of all life... Day by day, we're all destroying our most precious resource! If we humans suffer from our actions, well, maybe we'll end up getting what we deserve.",
                                            "Well then, you little scamp... It's the rope's end for you and your Pokémon!",
                                            "Well, would you look at that! I control the ocean and all its power, and yet here I am, beaten by a little tyke! All right, all right... You've made your point."]) if paged?("SOPHOCLES")
        tournament_list.insert(insertIndex,[:FRONTIER_Spenser,"Spenser","Ah... Now this is something else...",
                                            "Your Pokémon are wimpy because you're wimpy as a trainer!",1,
                                            "Did you know that I'm known as the Palace Maven? Yeah, I take care of the Battle Palace in the Battle Frontier, in the Hoenn region. We are one of the best, so try your hardest against us.",
                                            "My physical being is with Pokémon always! My heart beats as one with Pokémon always! Young one of a trainer! Do you believe in your Pokémon? Can you believe them through and through? If your bonds of trust are frail, you will never beat my brethren! The bond you share with your Pokémon! Prove it to me here!",
                                            "Gwahahah! Hah, you never fell for my bluster! Sorry for trying that stunt!"]) if paged?("SPENSER")
        tournament_list.insert(insertIndex,[:LEADER_Tate,"Tate","Maybe we weren't in sync?",
                                            "Yes, I love this team!",1,
                                            "My Lunatone acts strange sometimes. When it's a full moon, it starts spinning around really fast! I tried to get it to settle down, but it won't stop. I wonder what that's all about.",
                                            "I'll show you the power of teamwork!",
                                            "Aww..."]) if paged?("TATE")
        tournament_list.insert(insertIndex,[:LEADER_Terra,"Terra","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("TERRA")
        tournament_list.insert(insertIndex,[:LEADER_Texen,"Texen","You certainly are an unmatched talent!",
                                            "That was an extraordinary effort from both you and your Pokémon!",1,
                                            "That was an impressive battle! The spirit of my first partner, Larvesta - no, Volcarona - lives on in my current partners, too! I want to add your strength to their experience as well!",
                                            "I show everyone how wonderful it is to move forward together with Pokémon. Competing like this is probably the best way to show everyone!",
                                            "Well done! The ones who change the world are always the ones who pursue their dreams. That's right! They're just like you."]) if paged?("TEXEN")
        tournament_list.insert(insertIndex,[:FRONTIER_Thorton,"Thorton","Whoa! You sure showed me!",
                                            "See? Just as analyzed.",1,
                                            "Grrr... Still at 47 percent? Slower than I expected. Whoa! I was so focused, I didn't even see you there! I was trying to perform an update on my data-interpreting machine, see... But it's taking forever! The update's already been going for a hundred hours or so!",
                                            "My analysis yielded optimal results! Get ready to witness some truly amazing battles!",
                                            "Hmm... I got handed the loss here. It's not making me happy at all, losing. Even though I'm not happy, I did glean some useful data, I suppose. That makes me glad I battled you."]) if paged?("THORTON")
        tournament_list.insert(insertIndex,[:FRONTIER_Lucy,"Lucy","Darn!",
                                            "Looks like you ran out of luck.",1,
                                            "Normally, I'm content to keep conversations with other trainers focused on the topic of battle. But lately, I find myself talking to you about all kinds of things. Even trivial matters. I've never been one for idle chatter. I considered it a distraction, at best. But this rapport we have...well, I don't mind it.",
                                            "I'll make this quick!",
                                            "...You, I won't forget... ...Ever..."]) if paged?("LUCY")
        tournament_list.insert(insertIndex,[:RIVAL_Tierno,"Tierno","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("TIERNO")
        tournament_list.insert(insertIndex,[:LEADER_Valerie,"Valerie","Now I finally feel free...",
                                            "Do you want to know unending pain...like I have?",1,
                                            "The Pokémon... The flower Pokémon... The Pokémon that was given eternal life...",
                                            "Battle with me. I want to know what a \"trainer\" is.",
                                            "Thank you very much for battling with me."]) if paged?("Valerie")
        tournament_list.insert(insertIndex,[:LEADER_Volkner,"Volkner","You've got me beat... Your desire and the noble way your Pokémon battled for you... I even felt thrilled during our match. That was a very good battle.",
                                            "It was not shocking at all... That is not what I wanted!",1,
                                            "I like how your Pokémon respond to your earnest enthusiasm. I'm glad someone who knows how to enjoy Pokémon battles won the tournament.",
                                            "Since you've come this far, you must be quite strong... I hope you're the trainer who'll make me remember how fun it is to battle!",
                                            "...Hehehe. Hahahah! ...That was the most fun I've had in a battle since...I don't know when! It's also made me excited to know you and your team will keep battling to greater heights!"]) if paged?("VOLKNER")
        tournament_list.insert(insertIndex,[:LEADER_Wallace,"Wallace","That was wonderful work. You were elegant--infuriatingly so. And you know, it was utterly glorious!",
                                            "I've shown you plenty of the water illusions performed by me and my Pokémon!",1,
                                            "The reason for my defeat... It's... The grand illusion of water! It wasn't enough!",
                                            "Who can most elegantly dance with their Pokémon? Show me right here and now!",
                                            "Bravo! I realize now your authenticity and magnificence as a Pokémon trainer. I find much joy in having met you and your Pokémon."]) if paged?("WALLACE")
        tournament_list.insert(insertIndex,[:RIVAL_Victoria,"Victoria","The wonderful combination of you and your Pokémon! What a beautiful friendship!",
                                            "Extreme conditions really test you and train you!",1,
                                            "A tournament is a story, too... And the stars of this story were you and your Pokémon.",
                                            "There is also strength in being with other people and Pokémon. Receiving their support makes you stronger. I'll show you this power!",
                                            "You are strong! No, both you and your Pokémon are strong!"]) if paged?("VICTORIA")
        tournament_list.insert(insertIndex,[:XEN_Neved,"Neved","Oh my, oh my?",
                                            "Forget it. I should've never wasted my time with you.",1,
                                            "Your ability flies in the face of all probability. Just what is the source of your power?",
                                            "Have you calculated the chance of your victory? No? Well I have, and I can say it's not looking too bright for you...",
                                            "Probability is just probability, after all... Absolutes do not exist."]) if paged?("NEVED")
        tournament_list.insert(insertIndex,[:AETHER_Faba,"Faba","I will now concede defeat. But I think you came to see how great Bug-type Pokémon can be.",
                                            "Do you see now? The greatness of Bug-type Pokémon!",1,
                                            "I'm a huge fan of Bug Pokémon. Bug Pokémon are nasty-mean, and yet they're beautiful, too...",
                                            "Would you like to know why I enjoy battling so much? It's because I want to become perfect, just like my Bug Pokémon! Okay! Let me take you on!",
                                            "Battling is a deep and complex affair..."]) if paged?("FABA")
        tournament_list.insert(insertIndex,[:LEADER_Winona,"Winona","A trainer that commands Pokémon with more grace than I...",
                                            "Our elegant dance is finished!",1,
                                            "Your devotion... That's what brought you victory. It's praiseworthy.",
                                            "I have become one with bird Pokémon and have soared the skies... However grueling the battle, we have triumphed with grace... Witness the elegant choreography of my Pokémon and me!",
                                            "Though I fell to you, I will remain devoted to bird Pokémon."]) if paged?("WINONA")
        tournament_list.insert(insertIndex,[:LEADER_Wulfric,"Wulfric","Phew! You're really a strong trainer, that's for sure!",
                                            "The Pokémon on both sides tried sooo hard, didn't they?",1,
                                            "Even if it's just little by little, I'm learning about Pokémon. I'm thinking about how to bring out the best from everyone, but I still have a ways to go. Oh, I almost forgot! Congratulations on your victory!",
                                            "A Pokémon battle with you! I feel really excited!",
                                            "Thank you for being my opponent! Yep! I learned a lot! Know what? Recently, I've been thinking Pokémon stay by our sides to bring people together... I'm thinking of researching that!"]) if paged?("WULFRIC")
        tournament_list.insert(insertIndex,[:FLARE_Xerosic,"Xerosic","The pain of my Pokémon... I feel it, too!",
                                            "We're stronger together!",1,
                                            "I'm so glad I came from Unova! There are many different people and so many different Pokémon there! And you know what... In the Village of Dragons, people take living alongside Pokémon for granted. I was surprised some people in Unova didn't think that way!",
                                            "The trainers who come here are trainers who desire victory with every fiber of their being! And they are battling alongside Pokémon that have been through countless difficult battles! If I battle with people like that, not only will I get stronger, my Pokémon will, too! And we'll get to know each other even better! Okay! Brace yourself! I'm Iris, and I'm going to defeat you!",
                                            "I'm upset I couldn't win! But you know what? More than that, I'm happy! I mean, come on. By having a serious battle, you and your Pokémon, and me and my Pokémon, we all got to know one another better than before! Yep, we sure did!"]) if paged?("XEROSIC")
        tournament_list.insert(insertIndex,[:RIVAL_Brendan,"Brendan","It's a little annoying...",
                                            "There's no way you can beat me!",1,
                                            "You know, I have a friend named May. She's my best rival! I still remember the first time we had a Pokémon battle, back in the Hoenn region. I'd never had a heated Pokémon battle like that, where we both give it everything we have!",
                                            "I'll teach you what a real Pokémon battle is!",
                                            "That was a good battle, our Pokémon gave it their best!"]) if paged?("BRENDAN")
        tournament_list.insert(insertIndex,[:PLASMA_Zinzolin,"Zinzolin","Wahahahah! Alright, I lost! You gave me a thrill!",
                                            "Wahahahah! Well, I'm winning! Thrilling, right?",1,
                                            "Wahahahah! You're having some great victories! I'm so impressed by the way you battle that I can't help but laugh!",
                                            "You look like you have a lot of zip! That's a good thing. Wahahahaha! Then I, Wattson, shall electrify you with my Pokémon!",
                                            "Wahahahaha! I swell with optimism seeing a promising young trainer like you!"]) if paged?("ZINZOLIN")
        tournament_list.insert(insertIndex,[:KAHUNA_Hala,"Hala","Impressive. Your prowess is notable.",
                                            "How foolish...",1,
                                            "I can sense in you the strong desire to protect...something. You have a powerful spirit...",
                                            "I must remove the weak, incomplete human spirit from this world and bring it perfection! I will not let you get in my way...",
                                            "Interesting. And quite curious."]) if paged?("HALA")
        tournament_list.insert(insertIndex,[:ELITE_Lorelei,"Lorelei","You're so very, very good! My Pokémon had a good time, too!",
                                            "I believe luck is on my side today!~",1,
                                            "Whenever I battle someone tough, I smile. I cannot help it! How about you? What do you do? Do you laugh? Cry? Get angry?",
                                            "No need to worry. Let chance do what it does. Like surprises from the game board, life goes through twists and turns. No need to worry. Things will go as they will. But, enough of that. I know one thing for certain. You have arrived here not merely because you were lucky. Let us not waste any time. I wish to test your skills myself!",
                                            "Battling a wonderful trainer is always a happy occasion!"]) if paged?("LORELEI")
        tournament_list.insert(insertIndex,[:LEADER_Allister,"Allister","T-this is bad!",
                                            "Everyone's looking... I want to hide...",1,
                                            "Have you heard of Gigantamax? In Galar, it makes certain Pokémon change their appearance when they Dynamax. B-but I've heard that, for some reason, it is not the same way here... I was so shocked to learn that, my mask nearly fell off...",
                                            "...'M Allister. H-here...I go...",
                                            "You won't get away. I-I won't let you. I-I'm mad about strong trainers."]) if paged?("ALLISTER")
        tournament_list.insert(insertIndex,[:LEADER_Opal,"Opal","You're mighty! You're worthy of lots of respect.",
                                            "I sensed your will to win, but I don't lose!",1,
                                            "You won because your focus was far greater than that of the others! Yes! I have to focus even more as well!",
                                            "You're the opponent of Candice? Sure thing! I was waiting for someone tough!",
                                            "Wow! You're great! You've earned my respect! I think your focus and will bowled us over totally. But next time I'll focus even more and won't lose!"]) if paged?("OPAL")
        tournament_list.insert(insertIndex,[:LEADER_Valarie,"Valarie","I meant to make your head spin, but you shocked me instead.",
                                            "That was unsatisfying somehow... Will you give it your all next time?",1,
                                            "My Pokémon work hard for me, so I want to do what I can for them. And I want them to bathe in the glamorous spotlight as well. In that sense, your Pokémon were gleaming very brightly!",
                                            "The stage is ours. Watch out, our dazzling brilliance might just blind you!",
                                            "My, oh my... You have a sweet fighting style."]) if paged?("VALARIE")
        tournament_list.insert(insertIndex,[:LEADER_Bea,"Bea","Ohhh! No one enjoys losing, but you all were such great opponents!",
                                            "The photo from the moment of my victory will be a real winner. Alright!",1,
                                            "Even in another region, I'm always looking for the perfect shot. Very interesting, right?",
                                            "That determined expression... That glint in your eye that says you're up for challenges... It's fantastic! Now come at me! My lens is always focused on victory - I won't let anything ruin this shot!",
                                            "You and your Pokémon have shown me a whole new depth of field! Fantastic! Just fantastic!"]) if paged?("BEA")
        tournament_list.insert(insertIndex,[:LEADER_Erick,"Erick","Ngh...",
                                            "I can handle any obstacle, as long as I've got my Pokémon with me.",1,
                                            "Isn't it strange that when we are with Pokémon, going out is just so much more fun! #{$Trainer.name}! Try going to different places and talk to your Pokémon! I bet you'll find out so many things about them!",
                                            "Let's do this!",
                                            "Haha! Don't worry."]) if paged?("ERICK")
        tournament_list.insert(insertIndex,[:ELITE_Molayne,"Molayne","Oh, darn. I've gone and lost.",
                                            "I was hoping that I would be able to become stronger here...",1,
                                            "I did my training on Mt. Pyre. While I trained there, I gained the ability to communicate with Ghost-type Pokémon; the bond I developed with my Pokémon is extremely tight.",
                                            "Ahahaha! I'm Phoebe of the Hoenn Elite Four. So, come on, just try and see if you can even inflict damage on my Pokémon!",
                                            "There's definitely a bond between you and your Pokémon, too. I didn't recognize that fact, so it's only natural that I lost. Yup, I'd like to see how far your bond will carry you."]) if paged?("MOLAYNE")
        tournament_list.insert(insertIndex,[:RIVAL_Trevor,"Trevor","...Funny.",
                                            "...Slurp.",1,
                                            "I'm looking forward to... I'm looking forward to... When we...can meet again.",
                                            "...Ha.\m... ...Analyzing.\m...Hah.",
                                            "As anticipated. Unanticipated. You. Target lock...completed. Commencing...experiment. You. Forever. Aha..."]) if paged?("TREVOR")
        tournament_list.insert(insertIndex,[:RIVAL_May,"May","Ohoho, wow, you did it!",
                                            "There's no way I'll lose!",1,
                                            "When I see you, I always think I have to try harder. I wanna get stronger and see a lot of different places. You're the first person I've met who makes me feel passionate about these things...aside from Brendan, maybe!",
                                            "I'm gonna show you how my Pokémon are really strong!",
                                            "That sure was a fun battle!"]) if paged?("MAY")
        tournament_list.insert(insertIndex,[:LEADER_Adam,"Adam","Fight as hard as you can 'til you faint!",
                                            "We're standing firm!",1,
                                            "I always train to the extreme because I believe in our potential. That is how we became strong.",
                                            "Can you withstand our power? Hm? I see no fear in you. You look determined. Perfect for battle! Ready, #{$Trainer.name}? You will bow down to our overwhelming power! Hoo hah!",
                                            "Why?! ...How could we lose?"]) if paged?("ADAM")
        tournament_list.insert(insertIndex,[:TRAINER_Vivian,"Vivian","You're a wall that I am unable to surmount!",
                                            "Do not give up. That is all there really is to it. The most important lessons in life are simple.",1,
                                            "I wonder how I happened to find my selfish Tyrunt in the same place I found my sweet Amaura... Maybe our friendship goes above and beyond the walls of our differences.",
                                            "There is only one thing I wish for. That by surpassing one another, we find a way to even greater heights.",
                                            "Yes, this is the way it should be. This way both humans and Pokémon will grow."]) if paged?("VIVIAN")
        tournament_list.insert(insertIndex,[:RIVAL_Nim,"Nim","No way! Good job!",
                                            "Oh, come on! You have to try harder than that!",1,
                                            "If we ever battle again, I won't lose! Don't you forget it!",
                                            "Hey! Howdy! ...Wait, are you my next opponent? Is this right? Hmm... Hmhm... Are you sure you're up for me? Hmm... Well, all right! We'll take things easy to start with! Okay! Let's see you ignite my passion for battle!",
                                            "Ow, wait a second! You are tough after all! I like you!"]) if paged?("NIM")
        tournament_list.insert(insertIndex,[:TRAINER_Isha,"Isha","Hah... Hah... You're so strong... And so scary... I can't take any more...",
                                            "I'm s-s-so sorry! I didn't m-mean for anything like this to... It wasn't supposed to happen like this! Oh no... *Sniffle* *Sob*... I'm so sorry...",1,
                                            "Uh-umm, hi... Th-the weather is in a lovely way today, isn't it?",
                                            "I'll t-try t-t-to serve you as a Battle Chatelaine like my sisters, so... Please s-start the battle already!",
                                            "Um, fair play! You were so very strong! Th-the truth is I was nervous facing strangers. So I don't know what I did... B-but I will try even harder the next time!"]) if paged?("ISHA")
        tournament_list.insert(insertIndex,[:LEADER_Florin,"Florin","I'm definitely going to get stronger. Much, much, stronger.",
                                            "We'll keep pushing past our limits, you'll see!",1,
                                            "Hi! #{$Trainer.name}! I bet you're surprised to see me here! I made it all the way here, and it's all thanks to you! #{$Trainer.name}, losing to you that time made me stronger! But I'm not going to lose anymore! I'm going to win! For the Pokémon who gave me courage and strength!",
                                            "Get ready... Here I come!",
                                            "I've lost..."]) if paged?("FLORIN")
        tournament_list.insert(insertIndex,[:LEADER_Souta,"Souta","Nice! How'd you come up with that kind of battle plan? You gotta tell me!",
                                            "As long as we both have a good time, then I think we can call it a great battle, eh?",1,
                                            "You know, whenever I feel cramped, I go out on adventures. I feel that I can become a new me when I breathe some fresh air.",
                                            "All right! Let's go full powered on this one!",
                                            "Aww, man! I wanted to show off the best side of my Pokémon!"]) if paged?("SOUTA")
        tournament_list.insert(insertIndex,[:TRAINER_Spector,"Spector","Oh... I guess I was trying too hard...",
                                            "My Pokémon were able to make the most of their power when I did things my way!",1,
                                            "Your strength is the way you're able to express yourself. Everybody was very excited by your victory!",
                                            "I'm going to demonstrate the hot moves I honed close to a volcano!",
                                            "Your strength sure reminds me of someone... You must have battled with many different people and learned good things from them every time, huh?"]) if paged?("SPECTOR")
        tournament_list.insert(insertIndex,[:LEADER_Saki,"Saki","Not good. Seriously not good.",
                                            "I'm Janine! Remember this name!",1,
                                            "Everybody in the Fuchsia City Gym disguises themselves to look like me! You can imagine how hard it is to find me! It's really fun, and a lot of the challengers have good things to say about it, but...nobody realizes it's me if I ever dress up.",
                                            "I'm the real deal! I'll show you what it means to be a ninja master!",
                                            "...!!! So... So strong!"]) if paged?("SAKI")
        tournament_list.insert(insertIndex,[:LEADER_Ryland,"Ryland","Hmm! My sturdy Pokémon, defeated!",
                                            "Gwahahaha! How were my sturdy Pokémon?!",1,
                                            "Guhahahaha! I lost, but I saw something great. Well, guess I'll go back to Sinnoh and start my son's training over! All right! Next time I take part in the tournament, I'll play to win!",
                                            "Trainer! You're young, just like my son, Roark. With more young trainers taking charge, the future of Pokémon is bright! So, as a wall for young people, I'll take your challenge!",
                                            "Gwahahaha! You were strong enough to take down my prized team of Pokémon. I recognize your power. Please show your power to other trainers, too!"]) if paged?("RYLAND")
        tournament_list.insert(insertIndex,[:TRAINER_Anju,"Angie","Ahahaha, excellent! Very well, you are the winner.",
                                            "Ahahaha, I'm the winner! Which is to say, you lost.",1,
                                            "I see! Your elegance radiates glitz and glamor. It's only natural that you're winning the tournaments.",
                                            "Please, you shall bear witness to our artistry. A grand illusion of water sculpted by Pokémon and myself!",
                                            "From you, I sense the brilliant shine of skill that will overcome all! However, you are somewhat lacking in elegance. Perhaps I should make you a loan of my outfit? ...Hahaha, I merely jest!"]) if paged?("ANJU")
        tournament_list.insert(insertIndex,[:TRAINER_Leaf,"Leaf","How insolent.",
                                            "Oh? Are you finished already? Your Pokémon aren't bad, but you're laughably weak.",1,
                                            "Oh? Don't I know you? Listen. Don't come whining about poor Pokémon and other trivial junk like that. Now, if you'll excuse me...",
                                            "Take a bite of this, child!",
                                            "Losing to some child... Being careless cost me my dignity."]) if paged?("LEAF")
        tournament_list.insert(insertIndex,[:TRAINER_Kris,"Kris","Huh?! No way!",
                                            "Here's to our outstanding teamwork!",1,
                                            "Understanding ecosystems and the mechanisms of evolution is important, too... But I'm more interested in the minds of the Pokémon. I want to know about what they think and how they feel. I want to understand their emotions so that we can make the world more like how they want it.",
                                            "Heya everyone, I'm Kris! I've got a lot of confidence in my knowledge of Pokémon, so be ready!",
                                            "You have shown me new potential! Thank you so much!"]) if paged?("KRIS")
        tournament_list.insert(insertIndex,[:TRAINER_Hilbert,"Hilbert","Well, I've had enough... And just so you know, I didn't go easy on you.",
                                            "It's simple, hear! I wanted to win more than ya did!",1,
                                            "#{$Trainer.name}! Yer finally showin' some true grit, ain't ya. But I reckon you've still got some room to grow in those britches o' yers. Aim for the sky, I always say! If y'all can face yer opponent head on 'n' win -no cheap tricks- I reckon y'all have got some real skill!",
                                            "If ya want ta win, don't make excuses! Got it? If yer gonna bellyache, just forget 'bout fightin'! Well, I might be fussin' 'bout nothing when it comes to you.",
                                            "Fer such a young 'un, ya have an imposin' battle style. I wonder what kind a journey ya had that made ya so strong. But, I still don't like losin'!"]) if paged?("HILBERT")
        tournament_list.insert(insertIndex,[:TRAINER_Hilda,"Hilda","Bravo! You showed me the spark of trainers. However, let me say just one thing... Please move on to an even greater goal!",
                                            "I'm winning this time, but you have talent! Your tactics... reading... You have great skills. That's right! I would like to battle you again and again!",1,
                                            "Don't mind me; I'm just one of the siblings who run the Battle Subway in Unova.",
                                            "Do you understand Pokémon well? Can you hold onto your principles? Will you go onto victory, or defeat? All aboard!",
                                            "Bravo! Excellent! I am glad that I fought so hard against a wonderful trainer like you. That's right! We grow stronger by matching ourselves against a strong opponent."]) if paged?("HILDA")
        tournament_list.insert(insertIndex,[:TRAINER_Nate,"Nate","Well, aren't you good. I like that in a trainer.",
                                            "This is far from being backed into a corner!",1,
                                            "It's kind of hard to put into words what it is about Dark-type Pokémon that fascinates me so... They're so wild and adorable... *sigh* Words just don't do them justice!",
                                            "I'm Karen, of the Indigo Elite Four. I hope you can at least provide me a bit of entertainment.",
                                            "Strong Pokémon. Weak Pokémon. That is only the selfish perception of people. Truly skilled trainers should try to win with the Pokémon they love best. I like your style. You understand what's important."]) if paged?("NATE")
        tournament_list.insert(insertIndex,[:TRAINER_Rosa,"Rosa","Witnessing the noble spirits of you and your Pokémon in battle has really touched my heart...",
                                            "Oh, fantastic! What did you think? My team is pretty cool, right? It's a bit embarrassing to show off, but I love to show their best sides!",1,
                                            "Oh my! I never thought I would meet you here! Honestly, I didn't! Oh, but silly me, I should at least do these things right...",
                                            "I've been hoping that I would see you again! Battling against you and your Pokémon, all of you brimming with hope for the future... Honestly, it just fills me up with energy I need to keep facing each new day! It does!",
                                            "I just...I just don't know what to say... I can hardly express this feeling... Battling you and your Pokémon makes everything seem worth it!"]) if paged?("ROSA")
        tournament_list.insert(insertIndex,[:TRAINER_Aarune,"Aarune","The pain of my Pokémon... I feel it, too!",
                                            "We're stronger together!",1,
                                            "I'm so glad I came from Unova! There are many different people and so many different Pokémon there! And you know what... In the Village of Dragons, people take living alongside Pokémon for granted. I was surprised some people in Unova didn't think that way!",
                                            "The trainers who come here are trainers who desire victory with every fiber of their being! And they are battling alongside Pokémon that have been through countless difficult battles! If I battle with people like that, not only will I get stronger, my Pokémon will, too! And we'll get to know each other even better! Okay! Brace yourself! I'm Iris, and I'm going to defeat you!",
                                            "I'm upset I couldn't win! But you know what? More than that, I'm happy! I mean, come on. By having a serious battle, you and your Pokémon, and me and my Pokémon, we all got to know one another better than before! Yep, we sure did!"]) if paged?("AARUNE")
        tournament_list.insert(insertIndex,[:TRAINER_Lisia,"Lisia","Whoopsies.",
                                            "How amazing are we!",1,
                                            "I really want to get better at Pokémon battles! I have to work even harder! This chapter should be titled... \"A Sudden Encounter! Miraculous Contest Scouting!\" That's what I'd call it!",
                                            "We'll shine through you, just watch!",
                                            "Aww, too bad."]) if paged?("LISIA")
        tournament_list.insert(insertIndex,[:PROFESSOR_Oak,"Oak","Wahahahah! Alright, I lost! You gave me a thrill!",
                                            "Wahahahah! Well, I'm winning! Thrilling, right?",1,
                                            "Wahahahah! You're having some great victories! I'm so impressed by the way you battle that I can't help but laugh!",
                                            "You look like you have a lot of zip! That's a good thing. Wahahahaha! Then I, Wattson, shall electrify you with my Pokémon!",
                                            "Wahahahaha! I swell with optimism seeing a promising young trainer like you!"]) if paged?("OAK")
        tournament_list.insert(insertIndex,[:PROFESSOR_Sycamore,"Sycamore","How is this possible...",
                                            "I moved...one step ahead again.",1,
                                            "I'm desperate to know the secret of your strength. If I unlock the secret, my dream to see the legendary Pokémon may come true! ...Excuse me. I got ahead of myself. Congratulations on your victories.",
                                            "Fighting against stronger foes is my training! You're going to help me reach the next level.",
                                            "I don't think our potentials are so different. But you seem to have something... Something more than that..."]) if paged?("SYCAMORE")
        tournament_list.insert(insertIndex,[:MAGMA_Tabitha,"Tabitha","Ahyahya! So very intriguing!",
                                            "Ahya! And with that, I bid you adios!",1,
                                            "Ahyahya, you'll never win against our leader!",
                                            "Wait, you're quite young. No matter, this will be easy!",
                                            "Hehehe... So, I lost..."]) if paged?("TABITHA")
        tournament_list.insert(insertIndex,[:CHATELAINE_Dana,"Dana","The winner takes everything, and there's nothing left for the loser.",
                                            "If somebody wins, the person who fought against that person will lose.",1,
                                            "I hope someday you, too, will discover a Pokémon that draws your gaze with its beauty and charm in battle. When you do, I have a feeling you'll develop a new thirst for victory within you as well.",
                                            "Life is a serious battle, and you have to use the tools you're given. It's more important to master the cards you're holding than to complain about the ones your opponents were dealt. Let us begin. And may the best trainer win! Contests like this are proof that you are really living...",
                                            "When one loses, they lose everything... The next thing I'll look for will be victory, too!"]) if paged?("DANA")
        tournament_list.insert(insertIndex,[:CHATELAINE_Morgan,"Morgan","You're mighty! You're worthy of lots of respect.",
                                            "I sensed your will to win, but I don't lose!",1,
                                            "You won because your focus was far greater than that of the others! Yes! I have to focus even more as well!",
                                            "You're the opponent of Candice? Sure thing! I was waiting for someone tough!",
                                            "Wow! You're great! You've earned my respect! I think your focus and will bowled us over totally. But next time I'll focus even more and won't lose!"]) if paged?("MORGAN")
        tournament_list.insert(insertIndex,[:TRAINER_Looker,"Looker","You're proving yourself, good job!",
                                            "No matter, you can do better than this, I'm sure of it.",1,
                                            "How did all these trainers get here? That's what I need to find out.",
                                            "Show me you're capable of helping me out!",
                                            "You truly are determined, I appreciate that."]) if paged?("LOOKER")
        tournament_list.insert(insertIndex,[:LEADER_Gordie,"Gordie","Hunwah! It's gone and ended! How will I say this... I want more! I wanted to battle a lot more!",
                                            "I won, but I want more! I wanted to battle a lot more!",1,
                                            "Battling with you was fun! I hope your victory will put more smiles on people's faces!",
                                            "My Pokémon were toughened up by stormy white waters! They'll take everything you can throw at them and then pull you under! Victory will be ours! Come on, let's get it done!",
                                            "The styles of battling and winning are as widely varied as trainers are. Do you want to know how I battle? I battle so I can say I had fun at the end, whether I win or lose!"]) if paged?("GORDIE")
        tournament_list.insert(insertIndex,[:FLARE_Celosia,"Celosia","Oh, darn...",
                                            "Properly tempered steel won't be made rusty by things like this! If you keep training without giving up, I'm sure we'll see each other again.",1,
                                            "You are a better trainer than me, in both skill and kindness. Um... I don't know how to say this, but good luck...",
                                            "I use the... Clang! Steel type! ...Do you know about the Steel type? They are very cold, hard, sharp, and really strong! Um... I'm not lying.",
                                            "The blend of your kindness and your Pokémon's strength brought this victory to you. Um... Keep on doing your best... with your Pokémon."]) if paged?("CELOSIA")
        tournament_list.insert(insertIndex,[:FLARE_Mable,"Mable","...My time with you is drawing to a close.",
                                            "Wow. This makes me happy.",1,
                                            "If a trainer doesn't give good commands, Pokémon get hurt in battle… That's why I want to get better at battling. And it was fun for me and my Pokémon when we battled with you.",
                                            "...So? ...Are we going to battle, or what?",
                                            "...You're so strong. It makes me feel happy. ...I don't know why. This is a strange feeling..."]) if paged?("MABLE")
        tournament_list.insert(insertIndex,[:FLARE_Aliana,"Aliana","Oh, darn. I've gone and lost.",
                                            "I was hoping that I would be able to become stronger here...",1,
                                            "I did my training on Mt. Pyre. While I trained there, I gained the ability to communicate with Ghost-type Pokémon; the bond I developed with my Pokémon is extremely tight.",
                                            "Ahahaha! I'm Phoebe of the Hoenn Elite Four. So, come on, just try and see if you can even inflict damage on my Pokémon!",
                                            "There's definitely a bond between you and your Pokémon, too. I didn't recognize that fact, so it's only natural that I lost. Yup, I'd like to see how far your bond will carry you."]) if paged?("ALIANA")
        tournament_list.insert(insertIndex,[:LEADER_Chuck,"Chuck","No... Not...yet...",
                                            "See? My Pokémon were as strong as I said!",1,
                                            "Wahahah! I enjoyed battling you! But a loss is a loss! From now on, I'm going to train 24 hours a day!",
                                            "I have to warn you that I am a strong trainer! I spend a lot of time training under a pounding waterfall every day. What? It has nothing to do with Pokémon? ... That's true! ... Come on. We shall do battle!",
                                            "Hmm... I lost? How about that!"]) if paged?("CHUCK")
        tournament_list.insert(insertIndex,[:XEN_Anastasia,"Anastasia","Superb, it should be said.",
                                            "If you don't know what it truly takes for us to battle with Pokémon as partners, you will never prevail over me!",1,
                                            "Kids catching Pokémon are so adorable. I saw one recently that was so cute, I decided to say something. But that kid was scared of me and ran away. My old friend Briney has mentioned it from time to time, but do I really have such a scary face?",
                                            "My Pokémon and I are going to show you everything we've got! Well then, you had better get ready to try and stop me!",
                                            "You deserve every credit for coming this far as a Pokémon Trainer. You do seem to know what is needed. Yes, what a trainer needs is a true and virtuous heart. It is through their contact with trainers that Pokémon learn right from wrong. The influence of their trainers' good hearts helps them grow strong!"]) if paged?("ANASTASIA")
        tournament_list.insert(insertIndex,[:METEOR_Aster,"Aster","Oho! That hurt just about exactly as much as I figured!",
                                            "Hooaahhh! You clown!",1,
                                            "Hehehe! So you've come all the way here! Just wait until you face Archie...",
                                            "...Hoo! ...Haaahh! I'm... Heating up! Me! You! Pokémon! Mixing it up! Dueling! Hooah! Full on! I'm burning up! Well! Welll! Wellllll! Let's battle it out until we've got nothing left!",
                                            "That was fun! I knew you'd show me a good time! I look forward to facing you again someday!"]) if paged?("ASTER")
        tournament_list.insert(insertIndex,[:METEOR_Eclipse,"Eclipse","I knew it! That trainer smelled tough!",
                                            "We can keep aiming higher, as Pokémon Trainers and as people! And it's all thanks to our Pokémon! Come again! I want to keep aiming higher!",1,
                                            "In the arena. There we'll see who's stronger! Let's try hard to be the best!",
                                            "You and us! Our Pokémon! The strength we have! We'll give it our all! No holding back!",
                                            "So exciting! You and your Pokémon's combination! Amazing teamwork!"]) if paged?("ECLIPSE")
        tournament_list.insert(insertIndex,[:XEN_Eli,"Eli","Hah... Hah... You're so strong... And so scary... I can't take any more...",
                                            "I'm s-s-so sorry! I didn't m-mean for anything like this to... It wasn't supposed to happen like this! Oh no... *Sniffle* *Sob*... I'm so sorry...",1,
                                            "Uh-umm, hi... Th-the weather is in a lovely way today, isn't it?",
                                            "I'll t-try t-t-to serve you as a Battle Chatelaine like my sisters, so... Please s-start the battle already!",
                                            "Um, fair play! You were so very strong! Th-the truth is I was nervous facing strangers. So I don't know what I did... B-but I will try even harder the next time!"]) if paged?("ELI")
        tournament_list.insert(insertIndex,[:XEN_Sharon,"Sharon","I see. You getting here was no fluke. Your power is real.",
                                            "Hmm... Now what should I do...",1,
                                            "...Ah, hello. I was just reading a collection of observations on Pokémon in the wild. One article addresses the question why Pokémon would go into a Poké Ball. According to this article, this behavior is based on instinct. A weakened Pokémon will curl up tight in an effort to heal itself. The Poké Ball was invented to take advantage of that protective instinct. I imagine we'll see each other again in the Pokémon World Tournament. Take care.",
                                            "They say I am the toughest of the Sinnoh Elite Four. I'm afraid I will have to go all out against you to live up to that reputation.",
                                            "I'll be reading books until my next battle. That will calm my nerves, so that I may deal with all situations without panicking."]) if paged?("SHARON")
        tournament_list.insert(insertIndex,[:METEOR_ZEL,"ZEL","I'm definitely going to get stronger. Much, much, stronger.",
                                            "We'll keep pushing past our limits, you'll see!",1,
                                            "Hi! #{$Trainer.name}! I bet you're surprised to see me here! I made it all the way here, and it's all thanks to you! #{$Trainer.name}, losing to you that time made me stronger! But I'm not going to lose anymore! I'm going to win! For the Pokémon who gave me courage and strength!",
                                            "Get ready... Here I come!",
                                            "I've lost..."]) if paged?("ZEL")
        tournament_list.insert(insertIndex,[:LEADER_Lavender,"Lavender","I can't believe it's come to this! I must have gotten complacent.",
                                            "Winning is important, but what's more important is whether or not I've outdone myself.",1,
                                            "When I battled you, I couldn't help but smile... Because I was able to improve myself, and because you were an excellent trainer. I want to improve and win more elegantly, so I invite you to be my opponent again in the future, if you wish.",
                                            "Hmf... You still appear to possess a combination of strength and kindness. Very well. Make your best effort not to bore me with a yawn-inducing battle. Clear?",
                                            "You and your Pokémon are both excellent and elegant. To have been able to battle against such a splendid team... My Pokémon and I learned a lot! I offer you my thanks."]) if paged?("LAVENDER")
        tournament_list.insert(insertIndex,[:TRAINER_Calem,"Calem","Oh, heavens. What is this? How am I losing?",
                                            "You are strong. But it's me who won.",1,
                                            "I'm so very happy! Because you're so very strong! There's so much I can learn from you. I can become even stronger. When I do, let's battle again!",
                                            "I learned a lot of things in the Sinnoh region. Also, I study Pokémon very much. I have come to be a Gym Leader. And, uh, so it shall be that you challenge me. But I shall win. That is what the Gym Leader of Hearthome does, non?",
                                            "You are so fantastically strong. I know now why I have lost."]) if paged?("CALEM")
        tournament_list.insert(insertIndex,[:RIVAL_Shauna,"Shauna","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("SHAUNA")
        tournament_list.insert(insertIndex,[:TRAINER_Klara,"Klara","How lovely.",
                                            "Your journey will hold many surprises, and I hope many joys as well.",1,
                                            "Hmm? Oh, #{$Trainer.name}, wasn't it? I bet you haven't participated in the island challenge in Alola, but maybe you've at least heard of it...",
                                            "I won't be holding back! My Rock-type Pokémon will grind you to dust! Your Pokémon are going to go down in one hit! Hah!",
                                            "Diamonds only sparkle after coal is pushed to its absolute limit..."]) if paged?("KLARA")
        tournament_list.insert(insertIndex,[:TRAINER_Sordward,"Sordward","I'm sorry...",
                                            "United like this, our dream team has no chance of losing!",1,
                                            "I'm pretty good in a Pokémon battle, but when it comes to anything else, I can be a little scatterbrained. So, somebody else usually ends up having to bail me out...",
                                            "Don't worry about who has more experience! Let's just push each other to grow stronger like rivals do!",
                                            "Ehaha! That's the power of teamwork."]) if paged?("SORDWARD")
        tournament_list.insert(insertIndex,[:TRAINER_Shielbert,"Shielbert","I knew I shouldn't have endeavored such a meaningless thing...",
                                            "I knew I could only count on Pokémon to make me smile again...",1,
                                            "*Sigh* You again? As long as you leave me alone...",
                                            "The bond I've developed with my Pokémon is the only thing that gets me going...",
                                            "Life is nothing more than a cycle of pain, so why do we bother trying to reach happiness..."]) if paged?("SHIELBERT")
        tournament_list.insert(insertIndex,[:TRAINER_Mustard,"Mustard","NO! Jessie is going to kill me. Looks like Team Rocket's blasting off again!",
                                            "We were just getting to the good part!",1,
                                            "Huh, even Jessie and I were allowed in this tournament... They really accept everyone, even people like us, haha.",
                                            "Surrender now, or prepare to fight!",
                                            "I'm going to be blasted off, except this time by Jessie."]) if paged?("MUSTARD")
        tournament_list.insert(insertIndex,[:TRAINER_Avery,"Avery","Thud! That's the sound of your strength rocking me to my core!",
                                            "I am training to properly form my desire for victory.",1,
                                            "My own venerable grandfather is the only one I had to emulate growing up, so I am not familiar with your hip, groovy slang. \"Hip\" and \"groovy\" are modern slang words...right? Well, either way, I have gotten used to saying them now, and that's not likely to change.",
                                            "Do you want to try to take me and my Pokémon on at our full strength?",
                                            "I look forward to our next battle."]) if paged?("AVERY")
        tournament_list.insert(insertIndex,[:TRAINER_Honey,"Honey","Hmm. Seems as if my luck has run out.",
                                            "This is winter's harshness.",1,
                                            "If it's someone like you, I'm sure you'll keep winning and will find something important. Keep it up.",
                                            "I have seen and suffered much in my life. Since I am your elder, let me show you what I mean.",
                                            "I am impressed by your prowess. With your strong will, I know you will overcome all life's obstacles."]) if paged?("HONEY")
        tournament_list.insert(insertIndex,[:TRAINER_Peony,"Peony","Your passion for battle inspires me!",
                                            "Looks like my Trainer-Grow-Stronger Machine, Mach 2 is really working!",1,
                                            "Whew, I could sure use a bite to eat right now... Maybe I should invent a machine that can replicate food instantaneously!",
                                            "Oh! I'm glad that we got to meet yet again like this!",
                                            "I'm glad whenever I get to learn from other strong challengers. Thank you for the battle!"]) if paged?("PEONY")
        tournament_list.insert(insertIndex,[:TRAINER_Peonia,"Peonia","...! I don't believe it! I'd never even considered it! I'm blown away by this! You and your Pokémon are hot stuff!",
                                            "This situation... This is heating up! I'm blazing now!",1,
                                            "Sometimes people say that as a member of the Sinnoh Elite Four, I should dress more properly. But see, this is my style! I told them, if you're going to change your whole style just 'cause someone told you to, that's not very proper as a trainer, you know? Of course, the day after I said that, I went and burned my foot on Infernape's fire. Turns out wearing flip-flops has drawbacks. If someone gives you some advice, you should at least listen!",
                                            "This situation just cooks! The drama and tension sizzles! Flint, the fiery master of Fire Pokémon, is going to put you to the test! Let Flint see how hot your spirit burns!",
                                            "...Whew... Burnt right down to cinders... Keep going... I know your spirit burns hot. Your whole team does."]) if paged?("PEONIA")
        tournament_list.insert(insertIndex,[:TRAINER_Victor,"Victor","A true friendship with Pokémon takes time. Yeh can't force it, yeh little whippersnapper!",
                                            "Hohoho... Indeed. Frail little blades o' grass'll break through even concrete.",1,
                                            "Ho ho! The best things in life take time, sprout! Yeh've got to learn not to be so hasty, especially at suppertime!",
                                            "So here I am, whippersnapper! I'm sure I'll enjoy a Pokémon battle with yeh, sprout, sure as trees grow up!",
                                            "Yeh believe in yer Pokémon... And they believe in yeh, too... It was a fine battle, sprout."]) if paged?("VICTOR")
        tournament_list.insert(insertIndex,[:TRAINER_Gloria,"Gloria","Ugh! You're such a twerp! Looks like Team Rocket's blasting off again...",
                                            "What?! Did we just win? I... I didn't think that was possible! James, get the camera!",1,
                                            "Next time it's going to be the perfect time to show Team Rocket's potential, just watch!",
                                            "Prepare for trouble!",
                                            "Well, Team Rocket failed again... Should I be surprised?"]) if paged?("GLORIA")
        tournament_list.insert(insertIndex,[:TRAINER_Alexa,"Alexa","Well, there goes my hope of beating you to smithereens and becoming the winner myself!",
                                            "*Giggle* We're in full swing now!",1,
                                            "I love reading! You can find a book about pretty much anything, you know. Books can take us on journeys to fantastical worlds and tell the stories of people far away from us!",
                                            "Hiya! I'm here to bring an old royal touch to this tournament!",
                                            "I'm...I'm speechless! You've done me in!"]) if paged?("ALEXA")
        tournament_list.insert(insertIndex,[:PROFESSOR_Magnolia,"Magnolia","Oh, dear me...",
                                            "How can this be?",1,
                                            "Oh goodness, hello to you! You know, my grandparents came to Kalos from a distant region. They came from a town where the past lives on... When I was growing up at their knees, they raised me on tales of the Pokémon of time and space. It's really thanks to those stories that I decided to become a Dragon-type trainer.",
                                            "Oh, goodness, hello to you! I'm so glad you've joined us! I know that you're very strong. That will make this great fun!",
                                            "Oh, you! You're too much! You and your Pokémon are simply charming!"]) if paged?("MAGNOLIA")
        tournament_list.insert(insertIndex,[:TRAINER_Sonia,"Sonia","You are positively shining! Yes, it's important to always shine.",
                                            "I just had the perfect strategy, but you should keep doing your best!",1,
                                            "It's not battle results that interest me. Rather, it's the carefully-thought-out strategies or novel tactics employed by trainers. How those plans affect one's opponent and influence the outcome of battles, that is where my interest lies!",
                                            "In a sense, this is a trial. A trial to see whose battle strategy will succeed!",
                                            "Yes! You have emerged victorious!"]) if paged?("SONIA")
        tournament_list.insert(insertIndex,[:PROFESSOR_Bellis,"Bellis","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("BELLIS")
        tournament_list.insert(insertIndex,[:TRAINER_Bill,"Bill","It seems you're more challenging than I thought.",
                                            "Just like I wanted.",1,
                                            "Wow, this place is so exciting, so many people to meet, and so many new Pokémon to analyze, too!",
                                            "I'm so excited to see how your Pokémon perform in battle!",
                                            "Just as I feared, impressive!"]) if paged?("BILL")
        tournament_list.insert(insertIndex,[:PROFESSOR_Birch,"Birch","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("BIRCH")
        tournament_list.insert(insertIndex,[:TRAINER_Bonnie,"Bonnie","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("BONNIE")
        tournament_list.insert(insertIndex,[:TRAINER_Cedric,"Cedric Juniper","Wild! Your reason's already more toxic than mine!",
                                            "Hey, c'mon! Get serious! You gotta put more out there!",1,
                                            "Congrats on your win! Losing stinks, but still... You're a fun Pokémon Trainer to battle! I mean, c'mon! The Pokémon battling with you are all like, \"We're gonna win!\"",
                                            "Get ready! I'm gonna knock some sense outta ya!",
                                            "Wait! I was right in the middle of the chorus!"]) if paged?("CEDRIC")
        tournament_list.insert(insertIndex,[:TRAINER_Celio,"Celio","Pokémon battles are still not my kind of thing, but it's still fun!",
                                            "So I guess I can battle too!",1,
                                            "You seem very familiar to a trainer that I helped some time ago. I asked for his help in the Sevii Islands to complete the Pokémon Network machine. I hope we can cooperate with each other some day!",
                                            "I hope I can give you the expected experience!",
                                            "Oh well, at least I tried, right?"]) if paged?("CELIO")
        tournament_list.insert(insertIndex,[:GALACTIC_Charon,"Charon","Gah... what a mess...",
                                            "Fuhyahya! Just as expected.",1,
                                            "I need to find Cyrus, this situation is worse than I thought.",
                                            "My, my. Someone your age? This will be easy.",
                                            "Sigh... So impressionable and impetuous."]) if paged?("CHARON")
        tournament_list.insert(insertIndex,[:TRAINER_Anthea,"Anthea","Good job! You know what you're doing!",
                                            "Way to work! That was a good lesson, eh?",1,
                                            "I'm the Frontier Brain that tests your knowledge. I know it's hard to imagine with me lookin' like this. But knowledge ain't just somethin' you get by studyin'. In order to experience everything, you need to have a honed mind and body to handle it!",
                                            "Hey, hey! How's it going? You keeping up with your studies? This should be fun! I'm getting excited, hey! All right! Bring it on!",
                                            "Smart going! Heh... You're a pretty bright spark... Next time, I'll come after you hard. No holds barred, understand? You keep up your studies!"]) if paged?("ANTHEA")
        tournament_list.insert(insertIndex,[:TRAINER_Mary,"Mary","At least I got the chance to see this incredible match myself!",
                                            "I can be an interviewer AND an incredible trainer too, you know~.",1,
                                            "You were awesome in our match, it was really impressive. I'd love to show that to the people in Johto, they'd go crazy!",
                                            "It's so exciting being the main focus on the stage. Please, entertain me!",
                                            "That was amazing! Please let me have an interview with you sometime!"]) if paged?("MARY")
        tournament_list.insert(insertIndex,[:PROFESSOR_Elm,"Elm","Too powerful...",
                                            "This is the real power of studying Pokémon!",1,
                                            "All that crowd really got me nervous, but it was fun.",
                                            "Oh, we really have a crowd, don't we? Let's try our best at least.",
                                            "These Pokémon you have ...such incredible discoveries. Please let me study them after this."]) if paged?("ELM")
        tournament_list.insert(insertIndex,[:TRAINER_Fennel,"Fennel","Why did I have the misfortune of being born in the same time period as you...?",
                                            "We've shown you a truly great pink!",1,
                                            "Hrmph...",
                                            "I suppose I should prove beyond doubt just how pathetic you are and how strong I am.",
                                            "I couldn't win, but at least I was able to show everyone how great Fairy-types are."]) if paged?("FENNEL")
        tournament_list.insert(insertIndex,[:TRAINER_Kurt,"Kurt","This isn't good...",
                                            "The elderly can also put on a fight, you know!",1,
                                            "Did you know I make custom Poké Balls in the Johto region? Yeah,  in addition to making my own custom Balls out of Apricorns, I studied Poké Ball mechanics, and I'm known far and wide as a Poké Ball expert. It's just spectacular how they handle Pokémon inside them.",
                                            "You seem like a pretty tough trainer. Let me test that.",
                                            "All these different Poké Balls you hold, please show me them after this."]) if paged?("KURT")
        tournament_list.insert(insertIndex,[:TRAINER_Yancy,"Yancy","I fell behind, but only by an inch...",
                                            "Just as I expected.",1,
                                            "Oh, you're still wandering around here?",
                                            "I can't allow an ignorant child like you to get in our way. I, Maxie, will show you the consequences of meddling!",
                                            "You've really done it, child. You've shown a power that exceeds that of the great Maxie!"]) if paged?("YANCY")
        tournament_list.insert(insertIndex,[:TRAINER_Rachel,"Rachel","I'm glad we've got such a strong trainer, but I don't plan on losing the next one!",
                                            "Thanks for always giving me the chance to have the greatest battles.",1,
                                            "Believe in yourself and your Pokémon! If you trust in one another and carry on battling side by side long enough, then someday you might even become worthy rivals for me, the unbeatable Champion!",
                                            "#{$Trainer.name}! I've been waiting for you. Always knew you'd be able to win your way here. Now, how about you take on Challenger Leon with everything that you've got?",
                                            "Your Pokémon certainly look delighted to battle alongside you, #{$Trainer.name}! But of course they do! They're lucky enough to battle with a trainer who knows just how to draw out the best of them! That's it. I'm gonna be sure to draw out even more of my own team members from now on, too!"]) if paged?("RACHEL")
        tournament_list.insert(insertIndex,[:PROFESSOR_Samson,"Samson Oak","OH MY GOSH! How could I lose to you AGAIN?! I've had it with this abuse!",
                                            "Now you know why never to disturb a pretty lady on a stroll!",1,
                                            "This isn't over! I'll see you in the arena again; I'm sure of it!",
                                            "You should know never to disturb a pretty lady from her stroll! This is payback!",
                                            "Now I'll have to teach you to never embarass a lady in public as well..."]) if paged?("SAMSON_SM")
        tournament_list.insert(insertIndex,[:TRAINER_Sawyer,"Sawyer","You certainly are an unmatched talent!",
                                            "That was an extraordinary effort from both you and your Pokémon!",1,
                                            "That was an impressive battle! The spirit of my first partner, Larvesta - no, Volcarona - lives on in my current partners, too! I want to add your strength to their experience as well!",
                                            "I show everyone how wonderful it is to move forward together with Pokémon. Competing like this is probably the best way to show everyone!",
                                            "Well done! The ones who change the world are always the ones who pursue their dreams. That's right! They're just like you."]) if paged?("SAWYER")
        tournament_list.insert(insertIndex,[:TRAINER_Scott,"Scott","Now I finally feel free...",
                                            "Do you want to know unending pain...like I have?",1,
                                            "The Pokémon... The flower Pokémon... The Pokémon that was given eternal life...",
                                            "Battle with me. I want to know what a \"trainer\" is.",
                                            "Thank you very much for battling with me."]) if paged?("SCOTT")
        tournament_list.insert(insertIndex,[:TRAINER_Scottie,"Scottie","Darn!",
                                            "Looks like you ran out of luck.",1,
                                            "Normally, I'm content to keep conversations with other trainers focused on the topic of battle. But lately, I find myself talking to you about all kinds of things. Even trivial matters. I've never been one for idle chatter. I considered it a distraction, at best. But this rapport we have...well, I don't mind it.",
                                            "I'll make this quick!",
                                            "...You, I won't forget... ...Ever..."]) if paged?("SCOTTIE")
        tournament_list.insert(insertIndex,[:TRAINER_Bettie,"Bettie","NO! Jessie is going to kill me. Looks like Team Rocket's blasting off again!",
                                            "We were just getting to the good part!",1,
                                            "Huh, even Jessie and I were allowed in this tournament... They really accept everyone, even people like us, haha.",
                                            "Surrender now, or prepare to fight!",
                                            "I'm going to be blasted off, except this time by Jessie."]) if paged?("BETTIE")
        tournament_list.insert(insertIndex,[:RIVAL_Trace,"Trace","What?! Did I lose?",
                                            "I did it!",1,
                                            "You're going all out on everyone, it's so cool!",
                                            "I heard you're pretty good with Pokémon. Let me take a look.",
                                            "Aw jeez, not good."]) if paged?("TRACE")
        tournament_list.insert(insertIndex,[:TRAINER_Clear,"Clear","Hmm. Seems as if my luck has run out.",
                                            "This is winter's harshness.",1,
                                            "If it's someone like you, I'm sure you'll keep winning and will find something important. Keep it up.",
                                            "I have seen and suffered much in my life. Since I am your elder, let me show you what I mean.",
                                            "I am impressed by your prowess. With your strong will, I know you will overcome all life's obstacles."]) if paged?("CLEAR")
        tournament_list.insert(insertIndex,[:TRAINER_Kieran,"Kieran","Your passion for battle inspires me!",
                                            "Looks like my Trainer-Grow-Stronger Machine, Mach 2 is really working!",1,
                                            "Whew, I could sure use a bite to eat right now... Maybe I should invent a machine that can replicate food instantaneously!",
                                            "Oh! I'm glad that we got to meet yet again like this!",
                                            "I'm glad whenever I get to learn from other strong challengers. Thank you for the battle!"]) if paged?("KIERAN")
        tournament_list.insert(insertIndex,[:XEN_Cassandra,"Cassandra","...! I don't believe it! I'd never even considered it! I'm blown away by this! You and your Pokémon are hot stuff!",
                                            "This situation... This is heating up! I'm blazing now!",1,
                                            "Sometimes people say that as a member of the Sinnoh Elite Four, I should dress more properly. But see, this is my style! I told them, if you're going to change your whole style just 'cause someone told you to, that's not very proper as a trainer, you know? Of course, the day after I said that, I went and burned my foot on Infernape's fire. Turns out wearing flip-flops has drawbacks. If someone gives you some advice, you should at least listen!",
                                            "This situation just cooks! The drama and tension sizzles! Flint, the fiery master of Fire Pokémon, is going to put you to the test! Let Flint see how hot your spirit burns!",
                                            "...Whew... Burnt right down to cinders... Keep going... I know your spirit burns hot. Your whole team does."]) if paged?("CASSANDRA")
        tournament_list.insert(insertIndex,[:TRAINER_Hazuki,"Hazuki","A true friendship with Pokémon takes time. Yeh can't force it, yeh little whippersnapper!",
                                            "Hohoho... Indeed. Frail little blades o' grass'll break through even concrete.",1,
                                            "Ho ho! The best things in life take time, sprout! Yeh've got to learn not to be so hasty, especially at suppertime!",
                                            "So here I am, whippersnapper! I'm sure I'll enjoy a Pokémon battle with yeh, sprout, sure as trees grow up!",
                                            "Yeh believe in yer Pokémon... And they believe in yeh, too... It was a fine battle, sprout."]) if paged?("HAZUKI")
        tournament_list.insert(insertIndex,[:TRAINER_Melanie,"Melanie","Ugh! You're such a twerp! Looks like Team Rocket's blasting off again...",
                                            "What?! Did we just win? I... I didn't think that was possible! James, get the camera!",1,
                                            "Next time it's going to be the perfect time to show Team Rocket's potential, just watch!",
                                            "Prepare for trouble!",
                                            "Well, Team Rocket failed again... Should I be surprised?"]) if paged?("MELANIE")
        tournament_list.insert(insertIndex,[:TRAINER_Kanon,"Kanon","Well, there goes my hope of beating you to smithereens and becoming the winner myself!",
                                            "*Giggle* We're in full swing now!",1,
                                            "I love reading! You can find a book about pretty much anything, you know. Books can take us on journeys to fantastical worlds and tell the stories of people far away from us!",
                                            "Hiya! I'm here to bring an old royal touch to this tournament!",
                                            "I'm...I'm speechless! You've done me in!"]) if paged?("KANON")
        tournament_list.insert(insertIndex,[:TRAINER_Sina,"Sina","Oh, dear me...",
                                            "How can this be?",1,
                                            "Oh goodness, hello to you! You know, my grandparents came to Kalos from a distant region. They came from a town where the past lives on... When I was growing up at their knees, they raised me on tales of the Pokémon of time and space. It's really thanks to those stories that I decided to become a Dragon-type trainer.",
                                            "Oh, goodness, hello to you! I'm so glad you've joined us! I know that you're very strong. That will make this great fun!",
                                            "Oh, you! You're too much! You and your Pokémon are simply charming!"]) if paged?("SINA")
        tournament_list.insert(insertIndex,[:PROFESSOR_Juniper,"Juniper","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("JUNIPER")
        tournament_list.insert(insertIndex,[:PROFESSOR_Rowan,"Rowan","Aww, really? My Grass-type Pokémon are growing good and strong, too...",
                                            "Yes! My Pokémon and I are perfectly good!",1,
                                            "Amazing! Hey! How do you feel? I want to win and brag about my Pokémon, too!",
                                            "Let's cut to the good stuff! Let's get down to battle!",
                                            "You're really tough! Wasn't it hard for you to raise your Pokémon to be so good? I guess that's a measure of how much you love your Pokémon."]) if paged?("ROWAN")
        tournament_list.insert(insertIndex,[:TRAINER_Elio,"Elio","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("ELIO")
        tournament_list.insert(insertIndex,[:TRAINER_Selene,"Selene","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("SELENE")
        tournament_list.insert(insertIndex,[:TRAINER_Oleana,"Oleana","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("OLEANA")
        tournament_list.insert(insertIndex,[:TRAINER_Rose,"Rose","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("ROSE")
        tournament_list.insert(insertIndex,[:AETHER_Wicke,"Wicke","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("WICKE")
        tournament_list.insert(insertIndex,[:ROCKET_Archer,"Archer","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("ARCHER")
        tournament_list.insert(insertIndex,[:TRAINER_Zero,"Zero","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("ZERO")
        tournament_list.insert(insertIndex,[:LEADER_Shade,"Shade","Aww, really? My Grass-type Pokémon are growing good and strong, too...",
                                            "Yes! My Pokémon and I are perfectly good!",1,
                                            "Amazing! Hey! How do you feel? I want to win and brag about my Pokémon, too!",
                                            "Let's cut to the good stuff! Let's get down to battle!",
                                            "You're really tough! Wasn't it hard for you to raise your Pokémon to be so good? I guess that's a measure of how much you love your Pokémon."]) if paged?("SHADE")
        tournament_list.insert(insertIndex,[:LEADER_Kiki,"Kiki","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("KIKI")
        tournament_list.insert(insertIndex,[:TRAINER_Eve,"Eve","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("EVE")
        tournament_list.insert(insertIndex,[:TRAINER_Lumi,"Lumi","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("LUMI")
        tournament_list.insert(insertIndex,[:ELITE_Heather,"Heather","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("HEATHER")
        tournament_list.insert(insertIndex,[:ELITE_Laura,"Laura","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("LAURA")
        tournament_list.insert(insertIndex,[:ELITE_Anna,"Anna","Indeed...",
                                            "I'm very sorry...",1,
                                            "Being here somehow makes me nostalgic... I remember those days...",
                                            "So you're ready for me? Let's begin then, shall we? Let me see your talent in its entirety. No need to hold back.",
                                            "Thank you... I see no problem at all with your skills. Rather I would have to praise you for them."]) if paged?("ANNA")
        tournament_list.insert(insertIndex,[:CHAMPION_Lin,"Lin","Aww, really? My Grass-type Pokémon are growing good and strong, too...",
                                            "Yes! My Pokémon and I are perfectly good!",1,
                                            "Amazing! Hey! How do you feel? I want to win and brag about my Pokémon, too!",
                                            "Let's cut to the good stuff! Let's get down to battle!",
                                            "You're really tough! Wasn't it hard for you to raise your Pokémon to be so good? I guess that's a measure of how much you love your Pokémon."]) if paged?("LIN")
        tournament_list.insert(insertIndex,[:CHAMPION_Amethyst,"Amethyst","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("AMETHYST")
        tournament_list.insert(insertIndex,[:TRAINER_Taube,"Taube","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("TAUBE")
        tournament_list.insert(insertIndex,[:ELITE_Elena,"Elena","The power of grass has wilted... What an incredible challenger!",
                                            "Come on, then, it's time! You're about to be uprooted!",1,
                                            "Hmmm? You must be taking on the Gym challenge in this region, right? I must say I'm rather partial to Grass-type Pokémon, though. Nice to see you!",
                                            "Sure seems like you understand Pokémon real well. This is gonna be a doozy of a battle!",
                                            "That must have been a fulfilling Pokémon battle for you!"]) if paged?("ELENA")
        tournament_list.insert(insertIndex,[:METEOR_Ace,"Ace","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("ACE")
        tournament_list.insert(insertIndex,[:TRAINER_Zina,"Zina","Fweh! Too much!",
                                            "Now this! This is a smoking-hot situation!",1,
                                            "My big brother's one of the Elite Four. So of course it's only normal that I'd be better than ordinary folks. But that's not what I want. I want to be tough on my own terms. It wouldn't be fair to the Pokémon that chose to be with me.",
                                            "I can feel my Pokémon shivering inside their Poké Balls! It's out of anticipation, not fear!",
                                            "Heeheehee! So hot, you!"]) if paged?("ZINA")
    =end
        return tournament_list
      end
    end