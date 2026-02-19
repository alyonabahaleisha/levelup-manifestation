import Foundation

struct HiddenProgram: Identifiable {
    let id = UUID()
    let limiting: String
    let rewrite: String
    let area: LifeArea
}

extension HiddenProgram {

    static func programs(for area: LifeArea) -> [HiddenProgram] {
        all.filter { $0.area == area }
    }

    static let all: [HiddenProgram] = money + relationships + selfWorth + fear + body + career

    static let money: [HiddenProgram] = [
        HiddenProgram(
            limiting: "Money is hard to come by",
            rewrite: "Money flows to me through ease and alignment.",
            area: .money
        ),
        HiddenProgram(
            limiting: "I have to work very hard for everything",
            rewrite: "I create effortlessly and I am richly rewarded.",
            area: .money
        ),
        HiddenProgram(
            limiting: "Rich people are greedy or selfish",
            rewrite: "Wealth amplifies who I already am — generous, kind, and powerful.",
            area: .money
        ),
        HiddenProgram(
            limiting: "I'm not ready to have that much money",
            rewrite: "I am ready now, and I grow into more every single day.",
            area: .money
        ),
        HiddenProgram(
            limiting: "Money always slips through my fingers",
            rewrite: "Money loves to stay with me and quietly multiply.",
            area: .money
        ),
        HiddenProgram(
            limiting: "I don't deserve financial abundance",
            rewrite: "Abundance is my birthright and I receive it fully.",
            area: .money
        )
    ]

    static let relationships: [HiddenProgram] = [
        HiddenProgram(
            limiting: "Love always ends in pain",
            rewrite: "Love is safe, expansive, and always evolving.",
            area: .relationships
        ),
        HiddenProgram(
            limiting: "I have to be perfect to be loved",
            rewrite: "I am loved for exactly who I am, edges and all.",
            area: .relationships
        ),
        HiddenProgram(
            limiting: "People always leave",
            rewrite: "The right people stay and grow with me.",
            area: .relationships
        ),
        HiddenProgram(
            limiting: "I push people away",
            rewrite: "I attract and keep the connections I truly deserve.",
            area: .relationships
        ),
        HiddenProgram(
            limiting: "I'm too much for people",
            rewrite: "The right people find my depth and intensity magnetic.",
            area: .relationships
        ),
        HiddenProgram(
            limiting: "I'm always the one who cares more",
            rewrite: "I attract relationships of mutual love and devotion.",
            area: .relationships
        )
    ]

    static let selfWorth: [HiddenProgram] = [
        HiddenProgram(
            limiting: "I'm not good enough",
            rewrite: "I am more than enough — always have been.",
            area: .selfWorth
        ),
        HiddenProgram(
            limiting: "I need to earn my worth",
            rewrite: "My worth is inherent, unconditional, and unshakeable.",
            area: .selfWorth
        ),
        HiddenProgram(
            limiting: "Other people are more deserving than me",
            rewrite: "I deserve everything good that life has to offer.",
            area: .selfWorth
        ),
        HiddenProgram(
            limiting: "I don't deserve to take up space",
            rewrite: "I belong here. My presence is a gift.",
            area: .selfWorth
        ),
        HiddenProgram(
            limiting: "I'm too flawed to be truly loved",
            rewrite: "My wholeness includes all of my imperfections.",
            area: .selfWorth
        ),
        HiddenProgram(
            limiting: "I have to be useful to have value",
            rewrite: "My value exists completely apart from what I produce.",
            area: .selfWorth
        )
    ]

    static let fear: [HiddenProgram] = [
        HiddenProgram(
            limiting: "The world is not safe",
            rewrite: "I am protected, guided, and supported in every step.",
            area: .fear
        ),
        HiddenProgram(
            limiting: "If I fail I won't recover",
            rewrite: "Every setback makes me wiser and more resilient.",
            area: .fear
        ),
        HiddenProgram(
            limiting: "Something bad is always about to happen",
            rewrite: "Good things are always quietly unfolding for me.",
            area: .fear
        ),
        HiddenProgram(
            limiting: "I'm not brave enough",
            rewrite: "Courage lives in me and grows every time I act.",
            area: .fear
        ),
        HiddenProgram(
            limiting: "Being seen is dangerous",
            rewrite: "Being seen opens doors I haven't even imagined yet.",
            area: .fear
        ),
        HiddenProgram(
            limiting: "I always mess things up",
            rewrite: "I learn, I adjust, and I always find my way forward.",
            area: .fear
        )
    ]

    static let body: [HiddenProgram] = [
        HiddenProgram(
            limiting: "My body is broken or wrong",
            rewrite: "My body is constantly healing and moving toward wholeness.",
            area: .body
        ),
        HiddenProgram(
            limiting: "I'll never look the way I want",
            rewrite: "My body transforms beautifully when I treat it with love.",
            area: .body
        ),
        HiddenProgram(
            limiting: "I'm lazy and undisciplined",
            rewrite: "I move and nourish my body in ways that feel natural and joyful.",
            area: .body
        ),
        HiddenProgram(
            limiting: "My worth is tied to how I look",
            rewrite: "My value has absolutely nothing to do with my appearance.",
            area: .body
        ),
        HiddenProgram(
            limiting: "I've always struggled with my body",
            rewrite: "A new, loving relationship with my body begins right now.",
            area: .body
        ),
        HiddenProgram(
            limiting: "My body betrays me",
            rewrite: "My body is always doing its best to support me.",
            area: .body
        )
    ]

    static let career: [HiddenProgram] = [
        HiddenProgram(
            limiting: "Success is for other people",
            rewrite: "Success is my natural destination and I'm already on my way.",
            area: .career
        ),
        HiddenProgram(
            limiting: "I'm not talented enough",
            rewrite: "My unique gifts are exactly what the world needs.",
            area: .career
        ),
        HiddenProgram(
            limiting: "I have to hustle 24/7 to succeed",
            rewrite: "I succeed with ease, focus, and aligned action.",
            area: .career
        ),
        HiddenProgram(
            limiting: "It's too late for me",
            rewrite: "This is exactly the right time for my breakthrough.",
            area: .career
        ),
        HiddenProgram(
            limiting: "People don't take me seriously",
            rewrite: "I command respect through my presence and my work.",
            area: .career
        ),
        HiddenProgram(
            limiting: "I don't know enough to be successful",
            rewrite: "I know enough to start, and I'll learn everything else on the way.",
            area: .career
        )
    ]
}
