// Homepage story sections: "Why Spoony" bento, testimonials marquee, CTA banner.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/cebu_data.dart';
import '../../screens/booking_screen.dart';
import '../../screens/explore_screen.dart';
import '../safe_image.dart';
import '../wm_ui.dart';

const _kGreen = Color(0xFF3F7D58);
const _kGold = Color(0xFFF59E0B);

String _spotImage(String id) {
  for (final d in cebuDestinations) {
    if (d.id == id && d.images.isNotEmpty) return d.images.first;
  }
  return cebuDestinations.first.images.first;
}

Widget _eyebrow(String text, {bool center = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Wm.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Wm.accent.withValues(alpha: 0.2)),
      ),
      child: Text(text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
              color: Wm.accent, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.6)),
    );

TextStyle _title(bool mobile, {Color color = Wm.ink}) => GoogleFonts.poppins(
      fontSize: mobile ? 28 : 36,
      fontWeight: FontWeight.w700,
      height: 1.15,
      letterSpacing: -0.6,
      color: color,
    );

// ── 1. Why Spoony (bento) ────────────────────────────────────────────────────

class HomeWhySection extends StatelessWidget {
  final double hPad;
  const HomeWhySection({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    final wide = w >= 1100;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        WmBlurIn(child: _eyebrow('WHY SPOONY')),
        const SizedBox(height: 16),
        WmBlurIn(
          delay: const Duration(milliseconds: 80),
          child: Text('Travel Cebu\nthe easy way', style: _title(mobile)),
        ),
        const SizedBox(height: 16),
        WmBlurIn(
          delay: const Duration(milliseconds: 160),
          child: const Text(
            'Curated spots, smart day-by-day itineraries and secure booking — '
            'everything you need for island hopping, canyoneering and city tours in one place.',
            style: TextStyle(color: Wm.muted, fontSize: 15, height: 1.65),
          ),
        ),
        const SizedBox(height: 26),
        WmBlurIn(
          delay: const Duration(milliseconds: 240),
          child: WmShimmerButton(
            label: 'Plan my trip',
            icon: Icons.arrow_forward_rounded,
            onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
          ),
        ),
      ],
    );

    const features = [
      (Icons.route_rounded, Wm.accent, 'Smart itinerary', 'Optimized routes, distances and schedules for every day of your trip.'),
      (Icons.shield_rounded, _kGreen, 'Secure booking', 'Verified partners, transparent pricing and instant reference codes.'),
      (Icons.near_me_rounded, _kGold, 'Real-time tracking', 'Follow your driver live and get notified the moment they arrive.'),
    ];

    final photo = _PhotoFeature(image: _spotImage('osmena_peak'));
    final small = [
      for (var i = 0; i < features.length; i++)
        _FeatureCard(icon: features[i].$1, color: features[i].$2, title: features[i].$3, desc: features[i].$4),
    ];

    Widget bento;
    if (mobile) {
      bento = Column(children: [
        SizedBox(height: 240, child: photo),
        for (final c in small) ...[const SizedBox(height: 14), c],
      ]);
    } else {
      bento = SizedBox(
        height: 440,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(flex: 5, child: photo),
          const SizedBox(width: 16),
          Expanded(
            flex: 5,
            child: Column(children: [
              for (var i = 0; i < small.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                Expanded(child: small[i]),
              ],
            ]),
          ),
        ]),
      );
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 56 : 96),
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(flex: 4, child: intro),
              const SizedBox(width: 56),
              Expanded(flex: 7, child: WmBlurIn(delay: const Duration(milliseconds: 200), child: bento)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              intro,
              const SizedBox(height: 36),
              WmBlurIn(delay: const Duration(milliseconds: 200), child: bento),
            ]),
    );
  }
}

class _PhotoFeature extends StatefulWidget {
  final String image;
  const _PhotoFeature({required this.image});

  @override
  State<_PhotoFeature> createState() => _PhotoFeatureState();
}

class _PhotoFeatureState extends State<_PhotoFeature> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final credit = creditForUrl(widget.image);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Wm.rLarge - 4),
          boxShadow: Wm.shadow(_hover ? 1 : 0.3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Wm.rLarge - 4),
          child: Stack(fit: StackFit.expand, children: [
            WmZoomFrame(
              hoverOverride: _hover,
              child: SafeImage(widget.image, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Wm.ink)),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 1],
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                ),
              ),
            ),
            if (credit != null)
              Positioned(top: 12, right: 12, child: PhotoCreditChip(credit: credit, light: true)),
            Positioned(
              left: 22,
              right: 22,
              bottom: 22,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 21),
                ),
                const SizedBox(height: 14),
                Text('Local experiences',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, height: 1.2)),
                const SizedBox(height: 6),
                Text('59 handpicked spots — hidden falls, sandbars, heritage towns and mountain peaks.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13.5, height: 1.55)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  const _FeatureCard({required this.icon, required this.color, required this.title, required this.desc});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        padding: const EdgeInsets.all(20),
        decoration: Wm.card(hover: _hover, tint: widget.color),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          AnimatedContainer(
            duration: Wm.fast,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _hover ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 23),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(widget.title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Wm.ink)),
              const SizedBox(height: 4),
              Text(widget.desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Wm.muted, height: 1.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Meet your guides ─────────────────────────────────────────────────────────
// Team members travelers mention by name in Facebook reviews. Quotes are
// verbatim excerpts from those reviews. Add `photo:` (asset path or URL) once
// each guide has approved a photo; until then their initial is shown.

class _Guide {
  final String name;
  final String role;
  final String quote;
  final String quoteBy;
  final String? photo;
  // ignore: unused_element_parameter
  const _Guide({required this.name, required this.role, required this.quote, required this.quoteBy, this.photo});
}

const _guides = [
  _Guide(
    name: 'Kuya Rodjen',
    role: 'Organizer',
    quote: 'Our ever-reliable organizer who made sure everything was smooth and hassle-free',
    quoteBy: 'Christine F.',
  ),
  _Guide(
    name: 'Kuya Vincent',
    role: 'Driver · Guide · Photographer',
    quote: 'Driver, photographer, videographer, at human drone … sobrang solid!',
    quoteBy: 'Kristel D.',
  ),
  _Guide(
    name: 'Kuya Junjun',
    role: 'Driver & Tour Guide',
    quote: 'Sobrang bait and masayahin din ng driver.',
    quoteBy: 'Janella E.',
  ),
  _Guide(
    name: 'Kuya Christian',
    role: 'Driver',
    quote: 'He was funny, friendly, and always helpful.',
    quoteBy: 'Pung M.',
  ),
];

class HomeGuidesSection extends StatelessWidget {
  final double hPad;
  const HomeGuidesSection({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: mobile ? 56 : 88),
      child: Column(children: [
        WmBlurIn(child: _eyebrow('MEET YOUR GUIDES', center: true)),
        const SizedBox(height: 14),
        WmBlurIn(
          delay: const Duration(milliseconds: 80),
          child: Text('The kuyas travelers rave about', textAlign: TextAlign.center, style: _title(mobile)),
        ),
        const SizedBox(height: 10),
        WmBlurIn(
          delay: const Duration(milliseconds: 160),
          child: const Text('Drivers, guides and photographers who know Cebu inside out.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Wm.muted, height: 1.5)),
        ),
        SizedBox(height: mobile ? 30 : 44),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _guides.length; i++)
              _GuideCard(guide: _guides[i], color: _kCardColors[i % _kCardColors.length], width: mobile ? double.infinity : 260),
          ],
        ),
      ]),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final _Guide guide;
  final Color color;
  final double width;
  const _GuideCard({required this.guide, required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    final initial = guide.name.split(' ').last[0];
    return Container(
      width: width == double.infinity ? null : width,
      padding: const EdgeInsets.all(22),
      decoration: Wm.card(tint: color),
      child: Column(children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withValues(alpha: 0.14),
          backgroundImage: guide.photo == null
              ? null
              : (guide.photo!.startsWith('http') ? NetworkImage(guide.photo!) : AssetImage(guide.photo!)) as ImageProvider,
          child: guide.photo == null
              ? Text(initial, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 28))
              : null,
        ),
        const SizedBox(height: 14),
        Text(guide.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Wm.ink)),
        const SizedBox(height: 4),
        Text(guide.role,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(height: 14),
        Text('"${guide.quote}"',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Wm.inkSoft, height: 1.55, fontStyle: FontStyle.italic)),
        const SizedBox(height: 8),
        Text('— ${guide.quoteBy}, Facebook review', style: const TextStyle(fontSize: 11.5, color: Wm.muted)),
      ]),
    );
  }
}

// ── 2. Testimonials marquee ──────────────────────────────────────────────────

// Real reviews copied from facebook.com/CebuSpoony/reviews.
// Facebook reviews are "Recommends" (stars == null); older ones may carry a
// real 1–5 star rating. Never invent reviews or ratings here.
class _Review {
  final String name; // full name as on Facebook; shown shortened ("Juan D.")
  final String text; // verbatim review text
  final String date; // e.g. 'March 2025'
  final int? stars; // null = "Recommends"
  final String? trip; // optional tour/destination mentioned
  // ignore: unused_element_parameter
  const _Review({required this.name, required this.text, required this.date, this.stars, this.trip});
}

const _kFacebookReviewsUrl = 'https://www.facebook.com/CebuSpoony/reviews';

// Summary shown at the top of the Facebook reviews tab.
const _kFacebookSummary = '100% recommend · 44 reviews';

const List<_Review> _reviews = [
  _Review(
    name: 'Pung Mutita',
    date: 'October 2026',
    text: '⭐⭐⭐⭐⭐ เยี่ยมมาก Highly recommended! '
        'As a Thai traveler visiting the Philippines for the first time, I wanted to make the most of my Cebu trip '
        'with an itinerary tailored to my interests. I planned everything on short notice and wanted to include '
        'freediving, explore the mountains, visit a local night market, and choose my own accommodations. '
        'That’s when I found Spoony Cebu Travel and Tours, and I’m so glad I did! '
        'The admin was quick to respond, helpful, and full of great recommendations. Even when I had trouble with '
        'international bank transfers, they genuinely tried to help me find a solution. I really appreciated their '
        'flexibility and willingness to accommodate my plans. '
        'Since some days were dedicated to full-day freediving trips, the team adjusted the transportation '
        'arrangements to fit our schedule. Everything worked out well, and I was happy to have the freedom to plan '
        'the trip my way. '
        'A special shout-out to Kuya Christian, our driver!! He was funny, friendly, and always helpful. He shared '
        'local tips, helped carry our belongings, and took photos for us. My favorite part was having him show us '
        'around the night market and introduce us to delicious local food. We had such a great time. Oh, and he’s '
        'a pretty good singer too😆🚗 '
        'Thanks to the Spoony team, our first trip to the Philippines was such a memorable one. We had a great time '
        'in Cebu.  ขอบคุณค่ะ🙏🏻🇹🇭🫶🏻🇵🇭',
    trip: 'Custom Cebu Itinerary',
  ),
  _Review(
    name: 'MJ Villanueva',
    date: 'August 2026',
    text: 'Good morning po. 🌞😀 Thank you so much po for accommodating us and for the tour, it was absolutely the '
        'best! Even though our time was limited, we enjoyed every moment so much. Our driver was very approachable, '
        'friendly, and truly made the trip better. Everything went smoothly, and we had such a wonderful experience. '
        'We’ll definitely recommend this (page) to our friends and looking forward to booking again! ✨🥰',
  ),
  _Review(
    name: 'Katherine Palmario',
    date: 'June 2026',
    text: 'Highly recommended! Shoutout to Kuya Vincent, our driver/tour guide for our city tour. He shared lots of '
        'interesting trivia about Cebu, and a safe driver. He definitely made our trip more memorable! 💯',
    trip: 'City Tour',
  ),
  _Review(
    name: 'Ivy C. Arguelles',
    date: 'June 2026',
    text: 'Super highly recommended. Hi po Spoony Cebu. Thank you so much po for making our Cebu Trip enjoyable and '
        'fun. The private tour for Day 1 (June 28, 2026) is really fun and we’ve learned so much from Kuya Vincent po '
        'about Cebu. He’s been our Driver/Tour guide/Photographer. Ang gaganda ng mga shots. Kudos to you Kuya. 🫶🏻 '
        'Our Day 2 (June 29) is memorable since we’ve met new friends as part of the joiners. The water activities '
        'are great. Thank you also to Kuya Christian for the safe driving. Our Cebu trip is tiring but so worth it '
        'po. 💕 Continue to offer good service po. More power. Thank you so much po ulit. ❤️',
    trip: 'Private & Joiner Tour',
  ),
  _Review(
    name: 'Anitsirc Sabasalab',
    date: 'June 2026',
    text: 'Highly recommendable. First, fast ang transaction, on time ang pick up. Mabait ang driver and enjoy during '
        'travel maypa videoke pa.',
  ),
  _Review(
    name: 'Karla',
    date: 'May 2026',
    text: 'Highly recommended! Thank you Spoony Cebu Travel and Tours for the smooth 6 days trip. Plus a very '
        'accomodating and fun to be with tour guide Sir Vincent. He was a family to us during our 6 days trip with '
        'him. ❤️',
    trip: '6-Day Trip',
  ),
  _Review(
    name: 'Jannah Jessever Alora',
    date: 'May 2026',
    text: 'Of all the tours we had, Spoony Cebu Travel and Tours was the best!! We had the most amazing tour guides!! '
        'Shoutout for Kuya Vincent for literally driving us from North to South for 3 days straight. You are highly '
        'recommended super fun and entertaining. Will never forget the funniest tour guides for our canyoneering '
        'experience, parang di kami napagod sa kakatawa and how you constantly check up on us. We felt super safe '
        'and secured. Literally never a dull moment for the whole trip!! Also for Sir Rodjen, for accommodating all '
        'of my questions and making our whole tour possible. You’re missing out if hindi sila ang pinili niyong '
        'travel and tours!! Super worth it!! Will surely go back and will definitely choose them again to '
        'accommodate us. Thank you and praying for the growth of your business!! More tour packages to come!! 🩷',
    trip: '3-Day North to South',
  ),
  _Review(
    name: 'Lourielle Dianne',
    date: 'March 2026',
    text: '⭐⭐⭐⭐⭐ Last minute, decided to go on tour as a solo joiner. Had an amazing experience with the Oslob- '
        'Sumilon day tour package! Everything was well-organized from start to finish. The service was excellent, '
        'and our tour guide was incredibly kind, friendly, and knowledgeable—making the whole trip even more '
        'enjoyable. We got to visit so many beautiful places, and every part of the tour was smooth, fun, and '
        'memorable. You can really tell they care about giving guests the best experience possible. Highly '
        'recommended for anyone looking for a hassle-free and unforgettable travel adventure',
    trip: 'Oslob–Sumilon Day Tour',
  ),
  _Review(
    name: 'Bernarose A. Villegas',
    date: 'March 2026',
    text: 'super accommodating, love the environment',
  ),
  _Review(
    name: 'Rene Sunga',
    date: 'March 2026',
    text: 'thanks eman at Vincent sa maingat nyo pag dadrive at pag antabay samin,sana palagi kayo gabayan ng puon '
        'sainyong trabaho',
  ),
  _Review(
    name: 'RC Sun',
    date: 'March 2026',
    text: 'Many thanks to Spoony Cebu Travel and Tours for a smooth and stress-free Cebu city tour and '
        'Moalboal-Kawasan tour. Great service from Kuya Emman and Kuya Vincent, very professional, kind and fun '
        'drivers and guide. Thank you for your help. Surely will recommend!',
    trip: 'City & Moalboal–Kawasan',
  ),
  _Review(
    name: 'Ruby Naomi Millamina',
    date: 'February 2026',
    text: 'Super safe and accomodating 🙏 salamat po kay kuya vincent sa pag picture at video samin! Sa uulitin po 😊',
  ),
  _Review(
    name: 'Kristel Dane',
    date: 'January 2026',
    text: 'Napakagandang experience kasama ang Spoony Travel and Tours — at second time ko na ito sa kanila kaya '
        'masasabi kong consistent talaga ang galing at serbisyo! 💯 Mula umpisa hanggang dulo, maayos, organisado, '
        'at ramdam ang malasakit sa mga biyahero. Lalo na ang aming driver, photographer, videographer, at human '
        'drone na si Mark Vincent Branoco — sobrang solid! 👏🔥 Hindi lang mahusay magmaneho, kundi napakahusay din '
        'kumuha ng litrato at video. Sulit na sulit bawat kuha, bawat angle, at bawat moment. Talagang lodi ka! 🙌 '
        'Maraming salamat, Spoony Travel and Tours, sa isa na namang masaya, safe, at memorable na biyahe. Second '
        'time pa lang pero siguradong hindi ito ang huli! Highly recommended! 🌏✨ PS. Napatiktok din naman si Kuya '
        'Driver hehehe',
  ),
  _Review(
    name: 'Avigail Joyce Andrade Cabral',
    date: 'January 2026',
    text: 'Highly recommended! 10/10 ang aming naging experience ❤️ Sobrang saya at smooth ng naging travel namin. '
        'Ang babait din ng drivers at sila na rin mismo nagpipicture sa inyo. Super worth it! 💖',
  ),
  _Review(
    name: 'Fjh Monil',
    date: 'December 2025',
    text: 'Great service and very affordable🤗🤗🤗',
  ),
  _Review(
    name: 'Shaillaine Alones',
    date: 'October 2025',
    text: 'Easy transaction and budget friendly! Much recommended po 😊 God bless! 😊🙏🏽',
  ),
  _Review(
    name: 'RoseMarie Pelobello',
    date: 'September 2025',
    text: 'Thank you Spoony Cebu for the hassle free and budget-friendly tour, very accommodating and friendly din ng '
        'mga driver sa tour. Highly recommended!',
  ),
  _Review(
    name: 'Angel Adaya',
    date: 'September 2025',
    text: 'Highly recommended 💯 Daghang salamat Spoony and Sir Junjun sa smooth nga byahe ug makalingaw na '
        'experience during our 3D2N Cebu trip. Even the accommodations kay di gyud kamahayan, nindot ug limpyo (plus '
        'points na naay heater aron di mapasmo human sa laag hahaha) Until our next trip po! God bless and more '
        'powers to your business!',
    trip: '3D2N Cebu Trip',
  ),
  _Review(
    name: 'Syrah Quijano',
    date: 'July 2025',
    text: '⭐⭐⭐⭐⭐ We had such a great experience with Spoony Cebu Travel and Tour during our 4-day trip in Cebu '
        '(July 22–25)! From start to finish, everything was smooth and enjoyable. A special shoutout to Kuya Rodjan '
        'and Kuya Junjun, our driver and tour guide — super friendly, accommodating, and always ready to help us with '
        'our little requests. He’s also amazing at taking photos! We loved every shot and appreciated how he made '
        'each stop fun and memorable. Spoony Cebu Travel and Tour was very responsive to our inquiries on their page, '
        'which gave us peace of mind while planning our trip. As first-time Cebu visitors, our hard-earned money was '
        'truly worth it — thanks to this reliable and thoughtful travel agency. Highly recommended! 💙🚗✨',
    trip: '4-Day Cebu Trip',
  ),
  _Review(
    name: 'Shey Nudo',
    date: 'July 2025',
    text: 'Literal na HASSLE FREE!! 😍 Big thanks to this agency, super happy ng Cebu family trip namin from day 1 to '
        'day 4. Very recommended!! 💯👌',
    trip: 'Family Trip',
  ),
  _Review(
    name: 'Christine Coles - Fortes',
    date: 'July 2025',
    text: 'We had an amazing experience with Spoony Cebu Travel and Tour! Highly recommended for anyone planning to '
        'explore Cebu and Bohol. Their 7D6N package is super sulit and very affordable! Shoutout to the awesome team '
        'who made our trip extra special: ✨ Kuya Rodjen – our ever-reliable organizer who made sure everything was '
        'smooth and hassle-free 🚗 Kuya John – our Cebu City tour driver who brought us to the heart of the city 🌴 '
        'Kuya Jr – our Bohol tour driver who made the countryside tour unforgettable 🌊 Kuya Junjun – our driver for '
        'Oslob and Moalboal who brought us to breathtaking views and experiences These kuyas didn’t just drive us '
        'around – they showed us the real beauty of Cebu and Bohol. In fairness, hindi sila boring kasama (haha), but '
        'when it’s time to rest, you’ll get to rest comfortably during the trip. 💯 If kami ang tatanungin, we’d '
        'definitely book with them again on our next visit. Thank you, Spoony Cebu Travel and Tour, for a fun, safe, '
        'and sulit adventure! 🌴🚗💙',
    trip: '7D6N Cebu & Bohol',
  ),
  _Review(
    name: 'Janella Mae Ebora',
    date: 'July 2025',
    text: 'Very recommended po itong agency na ito when you’re planning to go to Cebu. Mabilis po sya kausap and very '
        'flexible sa gusto mong itinerary and schedule na gawin sa Cebu. Nasulit namin 4D3N tour sa kanila. Sobrang '
        'bait and masayahin din ng driver. Shoutout sayo Kuya Junjun na kamuka ni Piolo, miss ka na namin!!! See you '
        'soon Kuya 🫶🏻',
    trip: '4D3N Tour',
  ),
  _Review(
    name: 'Belle Vanessa Gutierrez Sarmiento-Madeja',
    date: 'March 2025',
    text: 'Hassle free & affordable. Highly recommeded! ⭐⭐⭐⭐⭐',
  ),
  _Review(
    name: 'Marielvic Palacio Ababa',
    date: 'March 2025',
    text: 'Thank you Spoony Cebu Travel and Tour for your se rvice with Kuya Arvin as our guide. highly recommended! '
        'Keep it up!',
  ),
  _Review(
    name: 'Lime De Castro Aquino',
    date: 'March 2025',
    text: 'Highly recommend ... kuddos sa inyo kuya Rodjel and ate rose at sa buong team... safety first at grabe ang '
        'babait kasama and chill lang talaga...',
  ),
  _Review(
    name: 'Zen Cui',
    date: 'February 2025',
    text: 'Highly recommended travel and tour! Sa DIY Travel Philippines group ko sila nakita at hindi naman ako na '
        'disappoint na sa kanila ako mag book 😊 Very kind and friendly and mga tour guide and drivers, very cozy ang '
        'mga room accommodation na binigay nila for us, 12pax. Sulit na sulit ang 5D4N namin with them 😍',
    trip: '5D4N Group Tour',
  ),
  _Review(
    name: 'Ralph John Gomiega',
    date: 'October 2024',
    text: 'Highly recommended! after booking, ride and enjoy nalang kayo sa tour nyo! Drivers are kind and friendly. '
        'Very accommodating! Definitely will book again! Salamat Spoony Cebu Travel and Tour!',
  ),
  _Review(
    name: 'Bhe Ortega Arapan',
    date: 'June 2024',
    text: 'Highly recommended!👍 It was my first time to book a travel tour and Thank God tama yung naging choice ko. '
        'Thank you Spoony Cebu Travel and Tour. Super nag-enjoy kami sa aming Cebu trip. Shout out kay Kuya Jun for '
        'assisting us and sa pagdrive nya mabilis pero swabe haha😁 Sa lahat din ng aming mga napuntahan at nameet '
        'don through them. Thank you po. Ang babait nila lahat. It was really a best birthday gift to me.😊 Godbless '
        'po and more travel to come.❤️',
  ),
  _Review(
    name: 'Charise Quillopo',
    date: 'June 2024',
    text: 'Highly recommended! 💯 Na-enjoy namin ang tour namin sa Cebu and Bohol. Mabait din ’yung owner and yung '
        'driver/guide namin.',
    trip: 'Cebu & Bohol Tour',
  ),
  _Review(
    name: 'Anna May Aljas Puertos',
    date: 'June 2024',
    text: 'sulit jud kaayo among Cebu Trip 😍 . highly recommended na tour package',
  ),
  _Review(
    name: 'Chris Bello',
    date: 'May 2024',
    text: 'Highly Recommended 💯🫶🏻✨ Super nag-enjoy ang family Namin in our 3D2N Exclusive Tour with Spoony! our '
        'coordinator, Kuya Nats is super kind, funny and approachable. He made our trip extra special at naging bff '
        'Ng papa ko hehehe The van is spacious for 7 pax and our accommodations in Mandaue and Oslob are comfortable '
        'and cozy ✨🫶🏻 Worth it going for this tour!',
    trip: '3D2N Exclusive Tour',
  ),
  _Review(
    name: 'Lesly Dimailig',
    date: 'April 2024',
    text: 'Highly recommended!! ✨ Super sulit ng tour!! Ang babait pa nilang lahat!! Na-attach na kami sa mga drivers '
        'namin haha, to Kuya Jub na sobrang chill kasama at kay Tatay Fred na super funny 🫶🏻 To Kuya Rodjen na very '
        'hands-on sa lahat ng guests, salute!!',
  ),
  _Review(
    name: 'Alyssa Velasquez',
    date: 'February 2024',
    text: 'Highly recommended!🫶🏻 For joiners tour super affordable! Sobrang cool din ng nag tourguide/driver samin '
        'kuya Leeeeeee nag enjoy po kami!!!💪 Instant human drone 😎 Thank youuu sa smoooth na city tour!🌝🤗',
    trip: 'Joiners City Tour',
  ),
  _Review(
    name: 'Corazon Abanilla - Sumague',
    date: 'December 2023',
    text: 'Highly recommended! Their packages are super AFFORDABLE. We avail Cebu-Oslob-Bohol EXCLUSIVE TOUR but '
        'it’s much affordable than the others. Thank you so much, Kuya Rodjen!',
    trip: 'Cebu–Oslob–Bohol Exclusive',
  ),
  _Review(
    name: 'Anette Ivann Rivera Santos',
    date: 'September 2019',
    text: 'Thank you sir rodjen for assisting us in our south cebu and city tour! It was a smooth and fun journey!!!',
    trip: 'South Cebu & City Tour',
  ),
  _Review(
    name: 'Gra Cia',
    date: 'August 2019',
    text: 'Thank you so much kuya rodjen for a hassle-free transaction and accomodating us even in a last minute. '
        'I send him a confirmation in less than 5 hours and will be in mactan airport. And he made to be there in '
        'the arrival to pick us up. Definitely I will recommend spoony tour cebu to those who are looking for a land '
        'arrangement and tour. He’s making his best to satisfy us in our tour in cebu and bohol. Til next time kuya 😊',
    trip: 'Cebu & Bohol Tour',
  ),
];

const _kCardColors = [Wm.accent, _kGreen, Color(0xFF6366F1), Color(0xFF0EA5E9), _kGold, Color(0xFFE11D48)];

/// "Juan Dela Cruz" -> "Juan D."
String _shortName(String full) {
  final parts = full.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return parts.first;
  return '${parts.first} ${parts.last[0].toUpperCase()}.';
}

class HomeTestimonialsSection extends StatefulWidget {
  final double hPad;
  const HomeTestimonialsSection({super.key, required this.hPad});

  @override
  State<HomeTestimonialsSection> createState() => _HomeTestimonialsSectionState();
}

class _HomeTestimonialsSectionState extends State<HomeTestimonialsSection> with SingleTickerProviderStateMixin {
  static const _cardW = 360.0;
  static const _gap = 20.0;
  static const _speed = 40.0; // px per second
  static final _setWidth = _reviews.length * (_cardW + _gap);

  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (_setWidth / _speed * 1000).round()),
  );
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.of(context).disableAnimations;
    if (_reduced) {
      _ctrl.stop();
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_reviews.isEmpty) return const SizedBox.shrink();
    final mobile = MediaQuery.of(context).size.width < 700;
    final header = Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.hPad),
      child: Column(children: [
        WmBlurIn(child: _eyebrow('TESTIMONIALS', center: true)),
        const SizedBox(height: 14),
        WmBlurIn(
          delay: const Duration(milliseconds: 80),
          child: Text('Loved by travelers', textAlign: TextAlign.center, style: _title(mobile)),
        ),
        const SizedBox(height: 10),
        WmBlurIn(
          delay: const Duration(milliseconds: 160),
          child: const Text('$_kFacebookSummary on Facebook',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Wm.muted, height: 1.5)),
        ),
        const SizedBox(height: 6),
        WmBlurIn(
          delay: const Duration(milliseconds: 220),
          child: TextButton.icon(
            onPressed: () => launchUrl(Uri.parse(_kFacebookReviewsUrl), mode: LaunchMode.externalApplication),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: const Text('Read all reviews on Facebook'),
          ),
        ),
      ]),
    );

    // Too few reviews to fill the screen → show them static and centered
    // instead of looping the same couple of cards.
    final screenW = MediaQuery.of(context).size.width;
    final fillsScreen = _reviews.length * ((mobile ? 300.0 : _cardW) + _gap) > screenW;

    Widget body;
    if (_reduced || !fillsScreen) {
      body = Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.hPad),
        child: Wrap(
          spacing: _gap,
          runSpacing: _gap,
          alignment: WrapAlignment.center,
          children: [
            for (var i = 0; i < _reviews.length; i++)
              _ReviewCard(review: _reviews[i], index: i, width: mobile ? double.infinity : _cardW),
          ],
        ),
      );
    } else {
      final cardW = mobile ? 300.0 : _cardW;
      final setW = _reviews.length * (cardW + _gap);
      final row = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var k = 0; k < 2; k++)
            for (var i = 0; i < _reviews.length; i++)
              Padding(
                  padding: const EdgeInsets.only(right: _gap),
                  child: _ReviewCard(review: _reviews[i], index: i, width: cardW)),
        ],
      );
      body = MouseRegion(
        onEnter: (_) => _ctrl.stop(),
        onExit: (_) {
          if (!_reduced) _ctrl.repeat();
        },
        child: ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
            stops: [0, 0.08, 0.92, 1],
          ).createShader(rect),
          blendMode: BlendMode.dstIn,
          child: SizedBox(
            height: 270,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, child) => OverflowBox(
                  alignment: Alignment.centerLeft,
                  minWidth: 0,
                  maxWidth: double.infinity,
                  child: Transform.translate(offset: Offset(-_ctrl.value * setW, 0), child: child),
                ),
                child: row,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Wm.surface,
      padding: EdgeInsets.symmetric(vertical: mobile ? 56 : 88),
      child: Column(children: [header, SizedBox(height: mobile ? 30 : 44), body]),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final _Review review;
  final int index;
  final double width;
  const _ReviewCard({required this.review, required this.index, required this.width});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.review;
    final color = _kCardColors[widget.index % _kCardColors.length];
    final name = _shortName(r.name);
    final initials = name.split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join();
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: Wm.fast,
        width: widget.width == double.infinity ? null : widget.width,
        height: widget.width == double.infinity ? null : 250,
        padding: const EdgeInsets.all(22),
        decoration: Wm.card(hover: _hover, tint: color),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            if (r.stars != null)
              for (var i = 0; i < 5; i++)
                Icon(Icons.star_rounded, size: 17, color: i < r.stars! ? _kGold : Wm.border)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                    color: const Color(0xFF1877F2).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(999)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.thumb_up_alt_rounded, size: 13, color: Color(0xFF1877F2)),
                  SizedBox(width: 5),
                  Text('Recommends',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1877F2))),
                ]),
              ),
            const Spacer(),
            Icon(Icons.format_quote_rounded, size: 26, color: color.withValues(alpha: 0.35)),
          ]),
          const SizedBox(height: 12),
          Flexible(
            fit: widget.width == double.infinity ? FlexFit.loose : FlexFit.tight,
            child: Text('"${r.text}"',
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: Wm.inkSoft, height: 1.6)),
          ),
          const SizedBox(height: 14),
          Row(children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: color.withValues(alpha: 0.14),
              child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Wm.ink)),
                Text(r.date.isEmpty ? 'Facebook' : 'Facebook · ${r.date}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: Wm.muted)),
              ]),
            ),
            if (r.trip != null) ...[
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Wm.chip, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_rounded, size: 12, color: Wm.accent),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(r.trip!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Wm.inkSoft)),
                  ),
                ]),
              ),
            ),
            ],
          ]),
        ]),
      ),
    );
  }
}

// ── 3. CTA banner ────────────────────────────────────────────────────────────

class HomeCtaBanner extends StatelessWidget {
  final double hPad;
  const HomeCtaBanner({super.key, required this.hPad});

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    final image = _spotImage('kalanggaman_island');
    final credit = creditForUrl(image);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 24 : 56, mobile ? 36 : 48, mobile ? 24 : 56, mobile ? 48 : 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text('Ready for your Cebu adventure?',
                style: GoogleFonts.poppins(
                    fontSize: mobile ? 28 : 40,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                    letterSpacing: -0.6,
                    color: Colors.white)),
          ),
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              'Pick your spots, choose joiner or premium, and we\'ll handle the rides, routes and reservations.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(spacing: 12, runSpacing: 12, children: [
            WmShimmerButton(
              label: 'Book a trip',
              icon: Icons.calendar_month_rounded,
              onTap: () => Navigator.pushNamed(context, BookingScreen.routeName),
            ),
            WmPressable(
              onTap: () => Navigator.pushNamed(context, ExploreScreen.routeName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Text('Explore destinations',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3)),
              ),
            ),
          ]),
        ],
      ),
    );

    final banner = ClipRRect(
      borderRadius: BorderRadius.circular(Wm.rLarge),
      child: Stack(children: [
        Positioned.fill(
          child: SafeImage(image, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(color: Wm.ink)),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: mobile ? Alignment.topCenter : Alignment.centerLeft,
                end: mobile ? Alignment.bottomCenter : Alignment.centerRight,
                colors: [Colors.black.withValues(alpha: 0.75), Colors.black.withValues(alpha: mobile ? 0.55 : 0.05)],
              ),
            ),
          ),
        ),
        if (mobile) content else SizedBox(height: 360, child: Align(alignment: Alignment.centerLeft, child: content)),
        if (credit != null)
          Positioned(right: 14, bottom: 14, child: PhotoCreditChip(credit: credit, light: true)),
      ]),
    );

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, mobile ? 40 : 72, hPad, mobile ? 40 : 72),
      child: WmBlurIn(
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Wm.rLarge), boxShadow: Wm.shadow(1)),
          child: banner,
        ),
      ),
    );
  }
}
