import Foundation
import Combine

// ANDROID: data class Affirmation(val id: String = UUID.randomUUID().toString(),
//   val text: String, val area: LifeArea, val isPersonal: Boolean = false)

struct Affirmation: Identifiable {
    var id: UUID = UUID()
    let text: String
    let area: LifeArea
    var isPersonal: Bool = false
}

// MARK: - Saved Programs Store
// ANDROID: SavedProgramsViewModel.kt (HiltViewModel)
//   val saved: StateFlow<List<Affirmation>> backed by DataStore JSON
//   fun save(program: HiddenProgram) — prepend Affirmation(isPersonal=true) + persist
//   fun isSaved(program: HiddenProgram): Boolean
//   Persist as JSON string list in DataStore<Preferences>: SAVED_PROGRAMS_KEY
//   Use Gson or kotlinx.serialization to serialize/deserialize List<Affirmation>

class SavedProgramsStore: ObservableObject {
    @Published var saved: [Affirmation] = []

    private let key = "saved_programs_v1"

    init() { load() }

    func save(_ program: HiddenProgram) {
        guard !isSaved(program) else { return }
        var affirmation = Affirmation(text: program.rewrite, area: program.area)
        affirmation.isPersonal = true
        saved.insert(affirmation, at: 0)
        persist()
    }

    func isSaved(_ program: HiddenProgram) -> Bool {
        saved.contains { $0.text == program.rewrite }
    }

    private func persist() {
        let data = saved.map { ["id": $0.id.uuidString, "text": $0.text, "area": $0.area.rawValue] }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.array(forKey: key) as? [[String: String]] else { return }
        saved = data.compactMap { dict in
            guard let idStr = dict["id"], let id = UUID(uuidString: idStr),
                  let text = dict["text"], let areaRaw = dict["area"],
                  let area = LifeArea(rawValue: areaRaw) else { return nil }
            return Affirmation(id: id, text: text, area: area, isPersonal: true)
        }
    }
}

extension Affirmation {

    static func feed(for areas: [LifeArea] = []) -> [Affirmation] {
        let pool = areas.isEmpty ? all : all.filter { areas.contains($0.area) }
        return pool.shuffled()
    }

    static let all: [Affirmation] = money + confidence + love + calm + career + feminineEnergy + relationships + selfWorth + fear + body

    static let money: [Affirmation] = [
        Affirmation(text: "Money flows to me easily and often.", area: .money),
        Affirmation(text: "I am magnetic to wealth and abundance.", area: .money),
        Affirmation(text: "My income expands beyond anything I've imagined.", area: .money),
        Affirmation(text: "I deserve to be richly rewarded for my gifts.", area: .money),
        Affirmation(text: "Prosperity is my natural state.", area: .money),
        Affirmation(text: "Every day I create more value and receive more wealth.", area: .money),
        Affirmation(text: "Money loves me and I welcome it fully.", area: .money),
        Affirmation(text: "Abundance is always available to me.", area: .money),
        Affirmation(text: "I attract financial opportunities effortlessly.", area: .money),
        Affirmation(text: "I am worthy of a luxurious, expansive life.", area: .money),
        Affirmation(text: "Wealth flows through me like a river.", area: .money),
        Affirmation(text: "My bank account reflects my inner abundance.", area: .money),
        Affirmation(text: "I receive money with grace and gratitude.", area: .money),
        Affirmation(text: "Opportunities to grow my wealth appear constantly.", area: .money),
        Affirmation(text: "I am open to all the ways money can come to me.", area: .money),
        Affirmation(text: "Financial freedom is my reality.", area: .money),
        Affirmation(text: "I choose wealth. Wealth chooses me.", area: .money),
        Affirmation(text: "My relationship with money is healthy, loving, and expansive.", area: .money),
        Affirmation(text: "I attract abundance in all forms.", area: .money),
        Affirmation(text: "Today money chooses me.", area: .money)
    ]

    static let confidence: [Affirmation] = [
        Affirmation(text: "I walk into every room knowing my worth.", area: .confidence),
        Affirmation(text: "I trust myself completely.", area: .confidence),
        Affirmation(text: "My presence alone creates impact.", area: .confidence),
        Affirmation(text: "I am exactly who I am meant to be.", area: .confidence),
        Affirmation(text: "I speak and people listen.", area: .confidence),
        Affirmation(text: "My confidence is rooted and unshakeable.", area: .confidence),
        Affirmation(text: "I own every room I enter.", area: .confidence),
        Affirmation(text: "I am enough, right now, exactly as I am.", area: .confidence),
        Affirmation(text: "I lead with certainty and grace.", area: .confidence),
        Affirmation(text: "My voice matters and deserves to be heard.", area: .confidence),
        Affirmation(text: "I radiate quiet, magnetic power.", area: .confidence),
        Affirmation(text: "I choose myself, always.", area: .confidence),
        Affirmation(text: "My standards are high because I know my value.", area: .confidence),
        Affirmation(text: "I am becoming more magnetic every day.", area: .confidence),
        Affirmation(text: "I trust my instincts completely.", area: .confidence),
        Affirmation(text: "I show up fully and unapologetically.", area: .confidence),
        Affirmation(text: "My inner knowing never steers me wrong.", area: .confidence),
        Affirmation(text: "I am bold, decisive, and clear.", area: .confidence),
        Affirmation(text: "I believe in myself as deeply as I believe in anything.", area: .confidence),
        Affirmation(text: "You walk into rooms and opportunities open.", area: .confidence)
    ]

    static let love: [Affirmation] = [
        Affirmation(text: "I am deeply loved and cherished.", area: .love),
        Affirmation(text: "Love finds me wherever I go.", area: .love),
        Affirmation(text: "I am worthy of a deep, expansive love.", area: .love),
        Affirmation(text: "My heart is open and love flows freely.", area: .love),
        Affirmation(text: "I attract relationships that lift me higher.", area: .love),
        Affirmation(text: "I am loved for exactly who I am.", area: .love),
        Affirmation(text: "The love I give returns to me multiplied.", area: .love),
        Affirmation(text: "I am a magnet for genuine, lasting connection.", area: .love),
        Affirmation(text: "My relationships are nourishing and joyful.", area: .love),
        Affirmation(text: "I deserve to be someone's first priority.", area: .love),
        Affirmation(text: "Love is safe and I welcome it fully.", area: .love),
        Affirmation(text: "I am adored, appreciated, and cherished.", area: .love),
        Affirmation(text: "The right people are drawn to my energy.", area: .love),
        Affirmation(text: "I receive love as easily as I give it.", area: .love),
        Affirmation(text: "My capacity for love expands every day.", area: .love),
        Affirmation(text: "I am a safe place for love to land.", area: .love),
        Affirmation(text: "Real, lasting love is my reality.", area: .love),
        Affirmation(text: "My partner sees me, chooses me, and adores me.", area: .love),
        Affirmation(text: "Love surrounds me in every direction.", area: .love),
        Affirmation(text: "I am magnetic to the love that is truly meant for me.", area: .love)
    ]

    static let calm: [Affirmation] = [
        Affirmation(text: "I am at peace with where I am right now.", area: .calm),
        Affirmation(text: "Stillness is my superpower.", area: .calm),
        Affirmation(text: "I breathe in calm and exhale all tension.", area: .calm),
        Affirmation(text: "My nervous system is safe and regulated.", area: .calm),
        Affirmation(text: "Peace is my natural state of being.", area: .calm),
        Affirmation(text: "I release what I cannot control.", area: .calm),
        Affirmation(text: "I move through life with ease and grace.", area: .calm),
        Affirmation(text: "Every breath brings me deeper into calm.", area: .calm),
        Affirmation(text: "I am grounded, centered, and serene.", area: .calm),
        Affirmation(text: "My mind is quiet and my heart is full.", area: .calm),
        Affirmation(text: "I trust the unfolding of my life.", area: .calm),
        Affirmation(text: "I am safe in this moment.", area: .calm),
        Affirmation(text: "Serenity lives within me always.", area: .calm),
        Affirmation(text: "I choose peace over worry, always.", area: .calm),
        Affirmation(text: "Calm is always only one breath away.", area: .calm),
        Affirmation(text: "I am the eye of the storm — still and certain.", area: .calm),
        Affirmation(text: "My inner peace cannot be disturbed.", area: .calm),
        Affirmation(text: "I rest deeply and wake up restored.", area: .calm),
        Affirmation(text: "Tranquility is my gift to myself.", area: .calm),
        Affirmation(text: "I am held. I am safe. I am calm.", area: .calm)
    ]

    static let career: [Affirmation] = [
        Affirmation(text: "My work creates extraordinary impact.", area: .career),
        Affirmation(text: "I am recognized and rewarded for my brilliance.", area: .career),
        Affirmation(text: "Opportunities I deserve come to me naturally.", area: .career),
        Affirmation(text: "I am building something that truly matters.", area: .career),
        Affirmation(text: "My career grows in full alignment with my purpose.", area: .career),
        Affirmation(text: "I attract the right collaborators and clients.", area: .career),
        Affirmation(text: "Success comes naturally to me.", area: .career),
        Affirmation(text: "I do work I love and it pays me abundantly.", area: .career),
        Affirmation(text: "My unique skills are in high demand.", area: .career),
        Affirmation(text: "I lead with vision and execute with precision.", area: .career),
        Affirmation(text: "Every step I take moves me toward my dream work.", area: .career),
        Affirmation(text: "I am exactly where I need to be right now.", area: .career),
        Affirmation(text: "My ambition is matched by my ability.", area: .career),
        Affirmation(text: "Doors open for me wherever I go.", area: .career),
        Affirmation(text: "I create my own success on my own terms.", area: .career),
        Affirmation(text: "I am undeniable in my field.", area: .career),
        Affirmation(text: "My work is my art and the world pays for it.", area: .career),
        Affirmation(text: "I am becoming the person my future self is proud of.", area: .career),
        Affirmation(text: "Everything I touch turns into growth.", area: .career),
        Affirmation(text: "My best career chapter is the one I'm writing now.", area: .career)
    ]

    static let feminineEnergy: [Affirmation] = [
        Affirmation(text: "My femininity is my greatest power.", area: .feminineEnergy),
        Affirmation(text: "I lead with softness and it moves mountains.", area: .feminineEnergy),
        Affirmation(text: "I receive as naturally as I give.", area: .feminineEnergy),
        Affirmation(text: "My intuition is my most trusted guide.", area: .feminineEnergy),
        Affirmation(text: "I am magnetic, radiant, and deeply alive.", area: .feminineEnergy),
        Affirmation(text: "I allow myself to be fully nourished.", area: .feminineEnergy),
        Affirmation(text: "My body is a temple I honor daily.", area: .feminineEnergy),
        Affirmation(text: "I embody grace in everything I do.", area: .feminineEnergy),
        Affirmation(text: "I am in flow with my natural rhythms.", area: .feminineEnergy),
        Affirmation(text: "My softness is strength.", area: .feminineEnergy),
        Affirmation(text: "I attract what I am — beauty, depth, and light.", area: .feminineEnergy),
        Affirmation(text: "I move through the world with elegance and ease.", area: .feminineEnergy),
        Affirmation(text: "My feminine essence draws abundance to me.", area: .feminineEnergy),
        Affirmation(text: "I am enough in my most natural state.", area: .feminineEnergy),
        Affirmation(text: "I radiate a warmth that touches everyone I meet.", area: .feminineEnergy),
        Affirmation(text: "I am a woman who knows herself completely.", area: .feminineEnergy),
        Affirmation(text: "I am the divine feminine, expressed fully.", area: .feminineEnergy),
        Affirmation(text: "Being a woman is my greatest gift.", area: .feminineEnergy),
        Affirmation(text: "My presence is a luxury.", area: .feminineEnergy),
        Affirmation(text: "I bloom in my own perfect time.", area: .feminineEnergy)
    ]

    static let relationships: [Affirmation] = [
        Affirmation(text: "My relationships are built on trust and depth.", area: .relationships),
        Affirmation(text: "I am surrounded by people who celebrate me.", area: .relationships),
        Affirmation(text: "I attract soul-level connections.", area: .relationships),
        Affirmation(text: "The people in my life bring out my best.", area: .relationships),
        Affirmation(text: "I communicate with openness and authenticity.", area: .relationships),
        Affirmation(text: "I set boundaries that honor my peace.", area: .relationships),
        Affirmation(text: "I am a joy to be around.", area: .relationships),
        Affirmation(text: "My connections deepen and flourish naturally.", area: .relationships),
        Affirmation(text: "I choose relationships that evolve me.", area: .relationships),
        Affirmation(text: "I am valued in every relationship I'm in.", area: .relationships),
        Affirmation(text: "Safe, nourishing connection is my birthright.", area: .relationships),
        Affirmation(text: "I show up fully in my relationships.", area: .relationships),
        Affirmation(text: "I attract friends who feel like family.", area: .relationships),
        Affirmation(text: "My circle is small, intentional, and extraordinary.", area: .relationships),
        Affirmation(text: "I release relationships that no longer serve me with love.", area: .relationships),
        Affirmation(text: "I give and receive freely in all my connections.", area: .relationships),
        Affirmation(text: "My energy draws in the right people every time.", area: .relationships),
        Affirmation(text: "I am deeply seen by the people who matter.", area: .relationships),
        Affirmation(text: "Every relationship I have is a reflection of my inner love.", area: .relationships),
        Affirmation(text: "I belong to a community that lifts me up.", area: .relationships)
    ]

    static let selfWorth: [Affirmation] = [
        Affirmation(text: "I am inherently valuable — no achievement required.", area: .selfWorth),
        Affirmation(text: "My worth is not up for debate.", area: .selfWorth),
        Affirmation(text: "I treat myself the way I deserve to be treated.", area: .selfWorth),
        Affirmation(text: "I am proud of who I am becoming.", area: .selfWorth),
        Affirmation(text: "I no longer shrink to make others comfortable.", area: .selfWorth),
        Affirmation(text: "I deserve the best — and I accept it.", area: .selfWorth),
        Affirmation(text: "My needs matter and I honor them.", area: .selfWorth),
        Affirmation(text: "I see myself clearly and I love what I see.", area: .selfWorth),
        Affirmation(text: "I am worthy of respect, love, and abundance.", area: .selfWorth),
        Affirmation(text: "I release the need for anyone's approval.", area: .selfWorth),
        Affirmation(text: "I belong in every room I enter.", area: .selfWorth),
        Affirmation(text: "My value is not determined by others' opinions.", area: .selfWorth),
        Affirmation(text: "I am whole, complete, and enough.", area: .selfWorth),
        Affirmation(text: "Self-love is not selfish — it is essential.", area: .selfWorth),
        Affirmation(text: "I choose myself first, always.", area: .selfWorth),
        Affirmation(text: "My worth was never something to earn.", area: .selfWorth),
        Affirmation(text: "I am allowed to take up space.", area: .selfWorth),
        Affirmation(text: "I am someone worth knowing deeply.", area: .selfWorth),
        Affirmation(text: "Everything I am is already enough.", area: .selfWorth),
        Affirmation(text: "I honor myself the way I honor those I love most.", area: .selfWorth)
    ]

    static let fear: [Affirmation] = [
        Affirmation(text: "I move through fear with quiet courage.", area: .fear),
        Affirmation(text: "The life I want is on the other side of this.", area: .fear),
        Affirmation(text: "Fear is just excitement waiting for direction.", area: .fear),
        Affirmation(text: "I am brave enough to begin.", area: .fear),
        Affirmation(text: "My courage grows every time I act despite fear.", area: .fear),
        Affirmation(text: "I trust myself to handle whatever comes.", area: .fear),
        Affirmation(text: "I release the past and step into possibility.", area: .fear),
        Affirmation(text: "Fear is not a stop sign — it is an invitation.", area: .fear),
        Affirmation(text: "I am safe to take up space and be fully seen.", area: .fear),
        Affirmation(text: "Every step forward dissolves the fear behind me.", area: .fear),
        Affirmation(text: "I choose expansion over contraction.", area: .fear),
        Affirmation(text: "The unknown holds gifts I haven't imagined yet.", area: .fear),
        Affirmation(text: "I breathe into discomfort and grow.", area: .fear),
        Affirmation(text: "I am supported as I move through uncertainty.", area: .fear),
        Affirmation(text: "My future self is cheering me on right now.", area: .fear),
        Affirmation(text: "I am stronger than any fear I face.", area: .fear),
        Affirmation(text: "Each day I become a little bolder.", area: .fear),
        Affirmation(text: "I walk through the fear and find freedom on the other side.", area: .fear),
        Affirmation(text: "Courage is my natural state when I remember who I am.", area: .fear),
        Affirmation(text: "I am ready. I have always been ready.", area: .fear)
    ]

    static let body: [Affirmation] = [
        Affirmation(text: "My body is beautiful exactly as it is.", area: .body),
        Affirmation(text: "I am grateful for everything my body does for me.", area: .body),
        Affirmation(text: "I nourish my body with love and intention.", area: .body),
        Affirmation(text: "My body grows stronger and more radiant every day.", area: .body),
        Affirmation(text: "I am at home in my body.", area: .body),
        Affirmation(text: "I move my body with pleasure and joy.", area: .body),
        Affirmation(text: "My body is my partner, not my enemy.", area: .body),
        Affirmation(text: "I treat my body like the luxury it is.", area: .body),
        Affirmation(text: "Health and vitality flow through every cell.", area: .body),
        Affirmation(text: "I listen to my body with kindness and curiosity.", area: .body),
        Affirmation(text: "My energy is vibrant and sustainable.", area: .body),
        Affirmation(text: "I glow from the inside out.", area: .body),
        Affirmation(text: "I deserve to feel incredible in my skin every day.", area: .body),
        Affirmation(text: "My body is a reflection of the love I give it.", area: .body),
        Affirmation(text: "I am becoming more radiant every day.", area: .body),
        Affirmation(text: "My body knows how to heal, thrive, and shine.", area: .body),
        Affirmation(text: "I choose foods and movement that make me feel alive.", area: .body),
        Affirmation(text: "My body is strong, capable, and worthy of love.", area: .body),
        Affirmation(text: "I am comfortable in my skin.", area: .body),
        Affirmation(text: "Every day my body and I grow closer together.", area: .body)
    ]
}
