/// English translations for the deck, keyed by card id. Turkish (deck.dart)
/// stays the canonical source; any id missing here falls back to Turkish.
class CardTr {
  const CardTr({
    required this.title,
    required this.prompt,
    required this.l0,
    required this.o0,
    required this.l1,
    required this.o1,
  });

  final String title;
  final String prompt;
  final String l0; // left label
  final String o0; // left outcome
  final String l1; // right label
  final String o1; // right outcome
}

const deckEn = <String, CardTr>{
  'kitlik': CardTr(
    title: 'Tribal Elder',
    prompt:
        'My Khan, the winter dragged on, the granaries are empty, the children hungry. Do we open the treasury for grain, or let the people tighten their belts?',
    l0: 'Open the treasury',
    o0: 'Grain was shared out; the people blessed your name.',
    l1: 'Let them endure',
    o1: 'The coffers held, but grumbling spread through the camp.',
  ),
  'akin': CardTr(
    title: 'Right-Wing Bey',
    prompt:
        'A neighbouring tribe raided our herds. Do we mount up and strike back, or settle without bloodshed and pay tribute?',
    l0: 'Ride to raid',
    o0: 'The herds were retaken; a few brave men fell.',
    l1: 'Pay tribute',
    o1: 'Peace was bought; the young called it weakness.',
  ),
  'kurultay': CardTr(
    title: 'Kurultay',
    prompt:
        'The beys demand a voice in the council, a share in the decisions. Do we grant it, or does the last word stay with the Khan?',
    l0: 'Grant a voice',
    o0: 'The beys are pleased; the old law loosened a little more.',
    l1: 'The last word is mine',
    o1: 'Authority held; the beys went sullen.',
  ),
  'evlilik': CardTr(
    title: 'Envoy of a Neighbour Tribe',
    prompt:
        'Our han wishes to give you his daughter and join our blood. Do we forge the alliance, or is our independence what matters?',
    l0: 'Accept the alliance',
    o0: 'A wedding was held; two tribes\' riders became one.',
    l1: 'Refuse',
    o1: 'Independence kept; the neighbour took offence.',
  ),
  'kuraklik': CardTr(
    title: 'Tribal Shaman',
    prompt:
        'The sky withheld its rain, the pastures yellowed. Do we hold a great sacrifice for Tengri, or call it superstition and get to work?',
    l0: 'Hold the rite',
    o0: 'Fires were lit; hope returned to the people\'s hearts.',
    l1: 'Superstition',
    o1: 'The shaman sulked; the elders shook their heads.',
  ),
  'kervan': CardTr(
    title: 'Sogdian Caravan Master',
    prompt:
        'My silk caravan wishes to cross your land. Do we levy a heavy toll, or let it pass free and grow the trade?',
    l0: 'Levy a heavy toll',
    o0: 'The purse filled; traders muttered of changing routes.',
    l1: 'Let it pass',
    o1: 'The market came alive, goods grew plentiful.',
  ),
  'isyan': CardTr(
    title: 'Rebel Bey',
    prompt:
        'A bey stopped his tribute and ignores your summons. Do we march and crush him, or talk and win him back?',
    l0: 'Crush him',
    o0: 'The revolt was put down; fear gripped the camp.',
    l1: 'Win him back',
    o1: 'The bey was soothed with gifts, but others took heart too.',
  ),
  'veba': CardTr(
    title: 'Healer',
    prompt:
        'A sickness stalks the camp. Do we keep the ill apart in their tents, or leave them to the shaman\'s chants?',
    l0: 'Keep them apart',
    o0: 'The plague slowed; the separated families are bitter.',
    l1: 'Leave it to the shaman',
    o1: 'Prayers were said; the sickness took a few more tents.',
  ),
  'at_surusu': CardTr(
    title: 'Chief Horse-Herder',
    prompt:
        'We found an ownerless herd on the steppe. Do we add the horses to the army, or give them to needy families?',
    l0: 'Add to the army',
    o0: 'The cavalry companies grew stronger.',
    l1: 'Give to the people',
    o1: 'The herders rejoiced; the beys were put out.',
  ),
  'cin_elcisi': CardTr(
    title: 'Tang Court Envoy',
    prompt:
        'The Emperor sends you silk, titles and gold, asking submission in return. Do we take the gifts and bow, or send the envoy back?',
    l0: 'Take the gifts',
    o0: 'The court drowned in gold; the steppe called it shame.',
    l1: 'Send him back',
    o1: 'The envoy left empty-handed; your honour was sung.',
  ),
  'vergi': CardTr(
    title: 'Treasury Scribe',
    prompt:
        'The purse has thinned, my Khan. Do we raise the tribute on the tribes, or ease the people\'s burden?',
    l0: 'Raise the tribute',
    o0: 'The treasury filled; murmurs rose in the villages.',
    l1: 'Ease the burden',
    o1: 'The people breathed easier; the ledgers ran red.',
  ),
  'genc_savascilar': CardTr(
    title: 'Young Cavalryman',
    prompt:
        'The young braves crave a raid for glory. Do we let them loose on the steppe, or hold the reins?',
    l0: 'Let them go',
    o0: 'They returned with loot; a few mothers buried their sons.',
    l1: 'Hold the reins',
    o1: 'The braves grumbled, but the camp found peace.',
  ),
  'kehanet': CardTr(
    title: 'Tribal Shaman',
    prompt:
        'I read a dark omen on the shoulder blade. Tengri calls the camp to move from this pasture. Do we migrate, or stay?',
    l0: 'Migrate',
    o0: 'The tents came down; a weary but obedient march.',
    l1: 'Stay',
    o1: 'We stayed put; the shaman muttered of ill fortune.',
  ),
  'esir': CardTr(
    title: 'Right-Wing Bey',
    prompt:
        'We brought captives from the war. Do we enslave them to labour, or release them for ransom?',
    l0: 'Set them to labour',
    o0: 'Hands were put to work; the elders called it against the law.',
    l1: 'Ransom them',
    o1: 'The purses filled; the captives returned home.',
  ),
  'dugun': CardTr(
    title: 'Chief Hatun',
    prompt:
        'Our heir\'s wedding nears. Do we throw a lavish feast that feeds every tribe, or keep it modest?',
    l0: 'Lavish feast',
    o0: 'Cauldrons boiled; your name was sung in seven tribes.',
    l1: 'Modest wedding',
    o1: 'The treasury was spared; gossip was not.',
  ),
  'su_kavgasi': CardTr(
    title: 'Dispute',
    prompt:
        'Two tribes drew knives over a river\'s water. Do we side with the stronger tribe, or share the water fairly?',
    l0: 'Side with the strong',
    o0: 'The strong tribe was won over; the weak nursed a grudge.',
    l1: 'Share it fairly',
    o1: 'Both tribes got a share; your justice was talked of.',
  ),
  'demirci': CardTr(
    title: 'Master of the Forge',
    prompt:
        'If I build a new water-forge our blades will be keener. Do we fund the forge, or guard the purse?',
    l0: 'Fund the forge',
    o0: 'Anvils rang; the army was armed with new steel.',
    l1: 'Guard the purse',
    o1: 'The smith sulked; we made do with old blades.',
  ),
  'yagma_payi': CardTr(
    title: 'Sharing the Spoils',
    prompt:
        'After the victory the loot must be divided. Do we give the lion\'s share to the beys, or to the people?',
    l0: 'Give to the beys',
    o0: 'The beys were sated; common braves grumbled.',
    l1: 'Give to the people',
    o1: 'The tents rejoiced; the beys frowned.',
  ),
  'casus': CardTr(
    title: 'Captain of the Guard',
    prompt:
        'We caught a spy, my Khan. Do we punish him before the people, or pay him to work for us?',
    l0: 'Punish him publicly',
    o0: 'It made an example; so did the fear.',
    l1: 'Turn him',
    o1: 'The spy turned; the enemy\'s secrets are ours now.',
  ),
  'eski_tore': CardTr(
    title: 'Tribal Elder',
    prompt:
        'The stern law of our ancestors is being forgotten. Do we revive the old codes, or move with the times?',
    l0: 'Revive the law',
    o0: 'The old code returned; the young had it hard.',
    l1: 'Move with the times',
    o1: 'The rules softened; the elders grieved.',
  ),
  'kuzey_boylari': CardTr(
    title: 'Northern Refugee',
    prompt:
        'Northern tribes fleeing the cold seek shelter in your camp. Do we take them in, or shut the gate?',
    l0: 'Take them in',
    o0: 'New braves joined the ranks; so did more mouths.',
    l1: 'Turn them away',
    o1: 'The gate closed; some froze in the steppe cold.',
  ),
  'altin_madeni': CardTr(
    title: 'Treasury Scribe',
    prompt:
        'A vein of gold was found in the mountains. Do we drive the people hard to dig it fast, or work it slow but willing?',
    l0: 'Force the labour',
    o0: 'Gold flowed; backs bent in the mine.',
    l1: 'Work it willingly',
    o1: 'Slow but peaceful; the purse filled gently.',
  ),
  'yabanci_din': CardTr(
    title: 'Wandering Preacher',
    prompt:
        'A new faith is spreading in the camp. Do we tolerate it, or ban it in the name of Tengri\'s law?',
    l0: 'Show tolerance',
    o0: 'Traders and converts pleased; the shamans uneasy.',
    l1: 'Ban it',
    o1: 'The old law held; some tents turned cold.',
  ),
  'ordugah': CardTr(
    title: 'Right-Wing Bey',
    prompt:
        'The soldiers\' pay is late and the tents are whispering. Do we open the treasury and pay now, or put it off until victory?',
    l0: 'Pay now',
    o0: 'The purse emptied; the soldiers\' eyes lit up.',
    l1: 'Put it off',
    o1: 'The treasury held; some companies slipped away at dusk.',
  ),
  'kiz_isteme': CardTr(
    title: 'Envoy of a Foreign Han',
    prompt:
        'The steppe\'s mightiest han wants your daughter. Do we give her and forge an alliance, or keep her at your side?',
    l0: 'Give your daughter',
    o0: 'Two realms became kin; a hearth went dark in the camp.',
    l1: 'Keep her',
    o1: 'The han took the refusal as insult; drums sounded at the border.',
  ),
  'yangin': CardTr(
    title: 'Tribal Elder',
    prompt:
        'A night fire burned half the camp. Do we give tents and herds from the treasury, or let the families rebuild themselves?',
    l0: 'Give from the treasury',
    o0: 'New tents rose; the people are grateful.',
    l1: 'Let them rebuild',
    o1: 'The treasury held; resentment lingered in the ashes.',
  ),
  'bilge': CardTr(
    title: 'Wandering Bard',
    prompt:
        'A bard says your victories are dragging you toward pride. Do we heed his counsel and stay humble, or cut him off?',
    l0: 'Heed the counsel',
    o0: 'Your humility was told across the steppe; the beys were startled.',
    l1: 'Cut him off',
    o1: 'The bard fell silent; your pride hardened.',
  ),
  'ticaret_yolu': CardTr(
    title: 'Sogdian Caravan Master',
    prompt:
        'A pass controls the lucrative Silk Road. Do we post a garrison and tax it, or leave it open and please the people?',
    l0: 'Post a garrison',
    o0: 'The toll flowed in; companies were tied down.',
    l1: 'Leave it open',
    o1: 'The roads thrived, goods grew cheap.',
  ),
  'kut': CardTr(
    title: 'Tribal Shaman',
    prompt:
        'Shall we proclaim that Tengri gave you the "kut" and hold a grand rite, or shall the Khan stay humble?',
    l0: 'Proclaim the kut',
    o0: 'Drums thundered; your mandate spread to seven climes.',
    l1: 'Stay humble',
    o1: 'No rite was held; some took it for weakness.',
  ),
  'salgin_hayvan': CardTr(
    title: 'Chief Horse-Herder',
    prompt:
        'A sickness struck the herds. Do we cull the sick beasts to stop it spreading, or leave it to the shaman\'s prayer?',
    l0: 'Cull them',
    o0: 'The sickness stopped; the herds thinned.',
    l1: 'Leave it to prayer',
    o1: 'Prayers were said; the sickness leapt to neighbouring herds.',
  ),
  'genc_varis': CardTr(
    title: 'Chief Hatun',
    prompt:
        'Our heir is wild, hungry for raids. Do we put him through hard discipline, or let him run free and grow his fame?',
    l0: 'Hard discipline',
    o0: 'The heir was reined in; a sullenness in his eye.',
    l1: 'Let him run free',
    o1: 'The youth rode to a raid; his fame and his recklessness both grew.',
  ),
  'yabanci_usta': CardTr(
    title: 'Wandering Craftsman',
    prompt:
        'Foreign masters wish to settle in our camp and teach their crafts. Do we accept and settle them, or turn them away?',
    l0: 'Settle them',
    o0: 'New goods appeared in the market; the old ways were shaken.',
    l1: 'Turn them away',
    o1: 'The masters went to another realm; the law was kept.',
  ),
  'kar_firtinasi': CardTr(
    title: 'Right-Wing Bey',
    prompt:
        'A terrible blizzard nears. Do we gather the herds and people into camp, or keep the army mobile and ready for the enemy?',
    l0: 'Gather into camp',
    o0: 'Tents filled, herds saved; the horses grew idle.',
    l1: 'Keep the army ready',
    o1: 'The army stayed sharp; a few herders were lost to the cold.',
  ),
  'adalet': CardTr(
    title: 'Captain of the Guard',
    prompt:
        'A bey killed a common herder. Do we punish the bey as the law demands, or take blood-money and close the matter?',
    l0: 'Punish the bey',
    o0: 'Your justice passed from tongue to tongue; the beys took fright.',
    l1: 'Take blood-money',
    o1: 'The bey went free; the herder\'s mother cursed the sky.',
  ),
  'buyuk_av': CardTr(
    title: 'The Great Hunt',
    prompt:
        'Shall we hold a great drive-hunt to bond the beys, or send everyone back to their work?',
    l0: 'Hold the hunt',
    o0: 'The beys hunted shoulder to shoulder; old bonds renewed.',
    l1: 'Back to work',
    o1: 'The hunt was cancelled; the chill among the beys lingered.',
  ),
  'yas': CardTr(
    title: 'Tribal Shaman',
    prompt:
        'The former khan has passed. Do we hold a long mourning and honour the rite, or grieve briefly and return to work?',
    l0: 'Long mourning',
    o0: 'The funeral rite ran for days; the law was honoured.',
    l1: 'Brief mourning',
    o1: 'We recovered quickly; the elders called it disrespect.',
  ),
  'kan_davasi': CardTr(
    title: 'Tribal Elder',
    prompt:
        'A blood feud is growing between two families. Do we step in and make peace, or let blood pay for blood as the law demands?',
    l0: 'Make peace',
    o0: 'Hands were clasped; some lamented vengeance unfulfilled.',
    l1: 'Apply the law',
    o1: 'Blood paid for blood; the law was served, the camp fell silent.',
  ),
  'kusatma': CardTr(
    title: 'Right-Wing Bey',
    prompt:
        'We have besieged the enemy fortress. Do we storm it now, or starve them into surrender?',
    l0: 'Storm it',
    o0: 'The fort fell; the walls were heaped with the brave dead.',
    l1: 'Starve them out',
    o1: 'The fort surrendered months later; patience cost dearly.',
  ),
  'ay_tutulmasi': CardTr(
    title: 'Tribal Shaman',
    prompt:
        'The moon ran red, the sky gave a warning. Do we appease Tengri with a great sacrifice, or refuse to bow to fear?',
    l0: 'Offer sacrifice',
    o0: 'Offerings were made; the frightened people calmed a little.',
    l1: 'Do not bow',
    o1: 'The Khan defied the sky; some felt courage, some dread.',
  ),
  'kole_pazari': CardTr(
    title: 'Sogdian Caravan Master',
    prompt:
        'I can sell the war captives for good money at my slave market. Do we sell, or keep clear of this trade?',
    l0: 'Sell them',
    o0: 'The purses filled; the elders called the gain filthy.',
    l1: 'Keep clear',
    o1: 'The captives never reached the market; the trader shrugged.',
  ),
  'sahte_para': CardTr(
    title: 'Treasury Scribe',
    prompt:
        'We could cut the gold in the coin and mint more, my Khan. Do we inflate the treasury this way, or keep the coin pure?',
    l0: 'Debase the coin',
    o0: 'The purse filled; prices leapt, trust was shaken.',
    l1: 'Keep it pure',
    o1: 'The coin kept its honour; traders flocked to the camp.',
  ),
  'ikinci_hatun': CardTr(
    title: 'Chief Hatun',
    prompt:
        'A bey offers his daughter as your hatun to seal an alliance. Do we take a second hatun and strengthen the bond, or stay true to your hearth?',
    l0: 'Take the hatun',
    o0: 'The alliance was sealed; a heart broke in the camp.',
    l1: 'Stay true',
    o1: 'Your loyalty was talked of; the bey withdrew his offer.',
  ),
  'sinir_komutasi': CardTr(
    title: 'Ambitious Bey',
    prompt:
        'Böri is loyal now, but ambitious. Do we give him command of the border march, or keep him before our eyes?',
    l0: 'Give him the border',
    o0: 'The border was secured; Böri grows strong, far away.',
    l1: 'Keep him close',
    o1: 'Böri stayed in camp; the border is a little weaker.',
  ),
  'duello': CardTr(
    title: 'Young Cavalryman',
    prompt:
        'The enemy offers to settle it with a single champion on the field rather than two armies. Do we send Alp Er to the field, or refuse and join battle?',
    l0: 'Send him out',
    o0: 'Alp Er won the duel; the camp feasted for a week.',
    l1: 'Refuse',
    o1: 'The challenge was declined; the enemy cried cowardice.',
  ),
  'yaralilar': CardTr(
    title: 'Healer',
    prompt:
        'The wounded returning from war are groaning. Do we open the treasury and heal them all, or leave them to their fate?',
    l0: 'Heal them',
    o0: 'The braves rose again; the army is grateful to its Khan.',
    l1: 'Leave them to fate',
    o1: 'The treasury held; groans rose from the tents.',
  ),
  'damizlik_at': CardTr(
    title: 'Chief Horse-Herder',
    prompt:
        'A neighbouring han offers heavy gold for our best breeding stallions. Do we sell, or keep the bloodline to ourselves?',
    l0: 'Sell them',
    o0: 'Gold flowed; the finest blood entered a rival\'s stable.',
    l1: 'Keep them',
    o1: 'The line stayed ours; our cavalry is the swiftest on the steppe.',
  ),
  'tang_prensesi': CardTr(
    title: 'Tang Court Envoy',
    prompt:
        'The Emperor offers a princess and a great dowry for peace. Do we accept and become kin, or guard the steppe\'s honour?',
    l0: 'Accept',
    o0: 'The court turned splendid; they whispered we had leaned toward China.',
    l1: 'Guard our honour',
    o1: 'The offer was refused; independence found its way into songs.',
  ),
  'kut_sorgusu': CardTr(
    title: 'Kurultay',
    prompt:
        'After a defeat the beys question your kut. Do we call a kurultay and renew your election, or crush the dissent and show authority?',
    l0: 'Call a kurultay',
    o0: 'The beys swore fealty anew; your legitimacy was renewed.',
    l1: 'Crush the dissent',
    o1: 'The voices were silenced; fear brought obedience, not love.',
  ),
  'esir_takasi': CardTr(
    title: 'Envoy of a Neighbour Tribe',
    prompt:
        'They want their captured bey back. Do we get him back through a prisoner exchange, or hold out for a heavy ransom?',
    l0: 'Make the exchange',
    o0: 'Our bey returned home; the ranks were renewed.',
    l1: 'Demand ransom',
    o1: 'The purse filled; the captive bey\'s family stayed bitter.',
  ),
  'suikast_plani': CardTr(
    title: 'Captain of the Guard',
    prompt:
        'We sensed an assassination plot among the guards, my Khan. Do we purge and replace the whole guard, or quietly remove the ringleader?',
    l0: 'Purge the guard',
    o0: 'The palace was cleansed; but security limped for a while.',
    l1: 'Remove the ringleader',
    o1: 'The danger was quietly erased; rumour spread in whispers.',
  ),
  'zirh_mi_kilic_mi': CardTr(
    title: 'Master of the Forge',
    prompt:
        'Our iron is limited. Do we forge armour to protect the people, or blades to cut down the enemy?',
    l0: 'Forge armour',
    o0: 'The braves were clad in armour; the people felt safe.',
    l1: 'Forge blades',
    o1: 'Keen blades were girded on; striking power grew.',
  ),
  'tapinak': CardTr(
    title: 'Wandering Preacher',
    prompt:
        'The believers ask leave and aid to build a temple. Do we fund the temple, or refuse in the name of Tengri\'s law?',
    l0: 'Fund the temple',
    o0: 'The temple rose; traders pleased, shamans aggrieved.',
    l1: 'Refuse',
    o1: 'The old law held; a congregation quietly turned cold.',
  ),
  'destan': CardTr(
    title: 'Wandering Bard',
    prompt:
        'I would compose an epic to make your victories immortal, my Khan. Do we host me and have the epic written, or is there no need to boast?',
    l0: 'Commission the epic',
    o0: 'Your name spread to seven tribes on the strings of the kopuz.',
    l1: 'No need',
    o1: 'The bard knocked on another door; your fame did not carry.',
  ),
  'su_kanali': CardTr(
    title: 'Wandering Craftsman',
    prompt:
        'If I dig a canal from the river your pastures will green and you can reap fields. Do we turn to a settled life, or stay true to the nomad law?',
    l0: 'Dig the canal',
    o0: 'The fields greened; some old nomads wept for the roaming life.',
    l1: 'Stay nomad',
    o1: 'The arrows turned to the steppe again; the law was kept.',
  ),
  'firariler': CardTr(
    title: 'Young Cavalryman',
    prompt:
        'A few soldiers who fled the battle were caught. Do we execute them for discipline, or pardon them and return them to the army?',
    l0: 'Execute them',
    o0: 'The ranks fell into line; fear settled over the tents.',
    l1: 'Pardon them',
    o1: 'Your mercy was talked of; some called it softness.',
  ),
  'varis_hasta': CardTr(
    title: 'Chief Hatun',
    prompt:
        'Our heir lies burning with fever. Do we summon a foreign physician, or leave him in the shaman\'s hands?',
    l0: 'Summon a physician',
    o0: 'Foreign medicine saved the heir; the shamans were aggrieved.',
    l1: 'Leave it to the shaman',
    o1: 'The shaman chanted for days; the heir pulled through, the law grew stronger.',
  ),
  'bori_geri_doner': CardTr(
    title: 'An Old Debt',
    prompt:
        'Böri, whom you once won over, has come to repay his debt: he offers a cavalry company to your command. Do we accept and take him in, or refuse with honour?',
    l0: 'Accept',
    o0: 'Böri kept his word; his company joined your banner.',
    l1: 'Refuse',
    o1: 'You forgave the debt; your nobility was talked of.',
  ),
  'cin_baski': CardTr(
    title: 'A Growing Appetite',
    prompt:
        'The Emperor uses his earlier gifts as pretext and now demands tribute and obedience. Do we bow and pay, or break the chain and resist?',
    l0: 'Bow and pay',
    o0: 'The tribute was sent; the steppe bowed its head.',
    l1: 'Resist',
    o1: 'The chain was broken; drums sounded again at the border.',
  ),
  'casus_ifsa': CardTr(
    title: 'Exposed',
    prompt:
        'The spy you turned has been exposed; the enemy learned of his double game. Do we sacrifice him, or smuggle him out and protect him?',
    l0: 'Sacrifice him',
    o0: 'The spy was given up; the trackers were thrown off.',
    l1: 'Protect him',
    o1: 'You shielded your man; loyalty worth its weight in gold.',
  ),
  'darbe_riski': CardTr(
    title: 'Restlessness',
    prompt:
        'The army has grown so strong that some commanders have begun to whisper. Do we soothe the leaders with rank, or cut the army down and disperse it?',
    l0: 'Soothe with rank',
    o0: 'Posts were handed out; the ambitions cooled, for now.',
    l1: 'Cut the army down',
    o1: 'Companies were disbanded; the danger eased, and so did our strength.',
  ),
  'kibir_tehlikesi': CardTr(
    title: 'Too Much Love',
    prompt:
        'The people love you so much the beys are jealous, saying "the Khan leans too far on the commons." Do we give the beys a share to win them, or trust in the people\'s love?',
    l0: 'Give the beys a share',
    o0: 'The beys were soothed with gifts; the people sulked a little.',
    l1: 'Trust the people',
    o1: 'You leaned on the people\'s love; the beys frown.',
  ),
  'iflas_riski': CardTr(
    title: 'An Empty Purse',
    prompt:
        'The treasury has hit bottom, my Khan. Do we levy an emergency raid-tax, or melt down the palace goods to get by?',
    l0: 'Emergency tax',
    o0: 'The purse filled a little; the people gritted their teeth.',
    l1: 'Melt the palace down',
    o1: 'Gold goods were melted; cash found at the cost of prestige.',
  ),
  'tore_catlagi': CardTr(
    title: 'A Cracking Law',
    prompt:
        'The law has been broken so often that shamans and elders are on the brink of revolt. Do we soothe them with a great rite and amnesty, or stand firm and defend the law?',
    l0: 'Rite and amnesty',
    o0: 'Fires were lit; the shamans\' anger cooled.',
    l1: 'Stand firm',
    o1: 'It was harshly put down; the law held, but through fear.',
  ),
  'altin_kibri': CardTr(
    title: 'Drowning in Gold',
    prompt:
        'The treasury overflows with gold; the court drifts to excess and the people grumble. Do we open the gold to the people and the war, or keep it in the vault?',
    l0: 'Open the gold',
    o0: 'The purse was opened; tents and ranks rejoiced.',
    l1: 'Keep it in the vault',
    o1: 'The gold was hoarded; decadence and gossip grew.',
  ),
  'ilk_oba_yeri': CardTr(
    title: 'The Founding',
    prompt:
        'We must choose a permanent camp site for our young dynasty. Do we settle on the fertile but open plain, or the sheltered but narrow valley?',
    l0: 'The open plain',
    o0: 'The herds multiplied; but the camp stayed open to attack.',
    l1: 'The sheltered valley',
    o1: 'The valley favours defence; the land is stingy.',
  ),
  'eyalet_isyani': CardTr(
    title: 'The Decline',
    prompt:
        'The dynasty has aged; distant provinces stopped paying tribute and declare independence. Do we retake them with a bloody campaign, or grant autonomy and keep the bond?',
    l0: 'Launch a campaign',
    o0: 'The revolt was crushed; but treasury and lives melted away.',
    l1: 'Grant autonomy',
    o1: 'The provinces held by a loose thread; the centre weakened.',
  ),
};
