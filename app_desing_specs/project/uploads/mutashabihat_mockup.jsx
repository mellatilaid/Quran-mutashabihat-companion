import React, { useState, useEffect, createContext, useContext } from "react";
import {
  Search, Heart, ChevronRight, ChevronLeft, Settings, BookOpen,
  Layers, User, Plus, X, Check, Sparkles, GraduationCap, Sun, Moon,
  Type as TypeIcon, RotateCcw, Trash2, EyeOff, Play, Pause, Share2,
  Flame, TrendingUp, Clock, AlertTriangle
} from "lucide-react";

/* =======================================================================
   DESIGN TOKENS — light + dark
   teal + gold are load-bearing (already committed in the Flutter code:
   teal seed color in main.dart, gold/amber highlight in the repository
   layer). One additional muted hue, rose, is introduced ONLY to
   distinguish a second phrase inside the same ayah — it never appears
   as a primary/nav/button color, so the two-color identity stays intact.
======================================================================= */
const LIGHT = {
  teal: "#0F6B62", tealDark: "#0B4E47", tealSoft: "#E4F0EE",
  gold: "#B8862E", goldSoft: "#F6E9CE",
  rose: "#9C4E68", roseSoft: "#F3E2E8",
  paper: "#FBF7EF", paperDeep: "#F3EDDF", cardBg: "#FFFFFF",
  ink: "#20302C", inkSoft: "#5C6B67", line: "#E2DAC7",
  danger: "#A34632", dangerSoft: "#FBEAE5", frame: "#0B4E47",
};

const DARK = {
  teal: "#4FBFAE", tealDark: "#0A1715", tealSoft: "#153531",
  gold: "#E3B45C", goldSoft: "#3A2E14",
  rose: "#D98CA8", roseSoft: "#3A2530",
  paper: "#121917", paperDeep: "#0A0F0E", cardBg: "#1B2422",
  ink: "#EDEDE4", inkSoft: "#93A19C", line: "#2A3532",
  danger: "#E38872", dangerSoft: "#33201B", frame: "#06110F",
};

const ThemeContext = createContext(LIGHT);
const useT = () => useContext(ThemeContext);

const colorTone = (T, name) =>
  name === "rose" ? { soft: T.roseSoft, strong: T.rose } : { soft: T.goldSoft, strong: T.gold };

const fontImport = `
@import url('https://fonts.googleapis.com/css2?family=Amiri:wght@400;700&family=Newsreader:opsz,wght@6..72,500;6..72,600&family=Inter:wght@400;500;600&display=swap');
`;

function arabicDigits(n) {
  const map = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
  return String(n).split("").map((d) => (map[+d] !== undefined ? map[+d] : d)).join("");
}

/* =======================================================================
   MOCK DATA — small illustrative subset standing in for real queries
   against app.db. Word ranges for 2:112 / phrase 988 match the real
   data we validated earlier (words 12-17, trailing "١١٢" marker).
======================================================================= */
const SURAHS = [
  { id: 1, ar: "الفاتحة", en: "Al-Fatihah", count: 1 },
  { id: 2, ar: "البقرة", en: "Al-Baqarah", count: 176 },
  { id: 3, ar: "آل عمران", en: "Ali 'Imran", count: 120 },
  { id: 4, ar: "النساء", en: "An-Nisa", count: 89 },
];

const AYAHS_BY_SURAH = {
  2: [
    { ayah: 5, text: "أُو۟لَـٰٓئِكَ عَلَىٰ هُدًى مِّن رَّبِّهِمْ ۖ وَأُو۟لَـٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ" },
    { ayah: 112, text: "بَلَىٰ مَنْ أَسْلَمَ وَجْهَهُۥ لِلَّهِ وَهُوَ مُحْسِنٌ فَلَهُۥٓ أَجْرُهُۥ عِندَ رَبِّهِۦ وَلَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ" },
    { ayah: 277, text: "إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ وَأَقَامُوا۟ ٱلصَّلَوٰةَ" },
  ],
};

const AYAH_WORDS = {
  "2:112": {
    words: ["بَلَىٰ", "مَنْ", "أَسْلَمَ", "وَجْهَهُۥ", "لِلَّهِ", "وَهُوَ", "مُحْسِنٌ", "فَلَهُۥٓ", "أَجْرُهُۥ", "عِندَ", "رَبِّهِۦ", "وَلَا", "خَوْفٌ", "عَلَيْهِمْ", "وَلَا", "هُمْ", "يَحْزَنُونَ"],
    endMarker: 112,
    phrases: [
      { id: 988, from: 12, to: 17, color: "gold", occurrences: 3 },
      { id: 512, from: 5, to: 6, color: "rose", occurrences: 2 },
    ],
  },
};

const PHRASE_OCCURRENCES = [
  { surah: 2, ayah: 112, words: ["وَلَا", "خَوْفٌ", "عَلَيْهِمْ", "وَلَا", "هُمْ", "يَحْزَنُونَ"], diffAt: 1 },
  { surah: 2, ayah: 38, words: ["فَلَا", "خَوْفٌ", "عَلَيْهِمْ", "وَلَا", "هُمْ", "يَحْزَنُونَ"], diffAt: 1 },
  { surah: 3, ayah: 170, words: ["وَلَا", "خَوْفٌ", "عَلَيْهِمْ", "وَلَا", "هُمْ", "يَحْزَنُونَ"], diffAt: 1 },
];

const SYSTEM_TIP = "The Al-Baqarah 112 version starts with وَلَا (\"and no fear\"), following a conditional \"whoever submits...\" — the Al-Baqarah 38 version starts with فَلَا (\"then no fear\"), following a direct address to Adam's descendants.";

const MOCK_PHRASES = [
  { id: 988, occurrenceCount: 13, surahCount: 7, sample: "وَلَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ" },
  { id: 742, occurrenceCount: 9, surahCount: 5, sample: "إِنَّ فِى ذَٰلِكَ لَءَايَةً" },
  { id: 305, occurrenceCount: 6, surahCount: 4, sample: "وَٱتَّقُوا۟ ٱللَّهَ لَعَلَّكُمْ تُفْلِحُونَ" },
].sort((a, b) => b.occurrenceCount - a.occurrenceCount);

const INITIAL_FAVORITES = [
  { surah: 2, ayah: 112, misses: 2, lastAttemptedDaysAgo: 9 },
  { surah: 3, ayah: 170, misses: 0, lastAttemptedDaysAgo: 1 },
];

const INITIAL_MY_AYAHS = [
  {
    surah: 2, ayah: 286,
    note: "Long ayah, always lose my place mid-way",
    full: "لَا يُكَلِّفُ ٱللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا ٱكْتَسَبَتْ",
  },
];

const CONFIDENCE = [
  { surah: 1, en: "Al-Fatihah", pct: 100 },
  { surah: 2, en: "Al-Baqarah", pct: 64 },
  { surah: 3, en: "Ali 'Imran", pct: 41 },
];

/* =======================================================================
   SHARED UI ATOMS
======================================================================= */
function TopBar({ title, onBack, right }) {
  const T = useT();
  return (
    <div className="flex items-center justify-between px-4 shrink-0" style={{ height: 56, background: T.paper, borderBottom: `1px solid ${T.line}` }}>
      <div className="flex items-center gap-2 min-w-0">
        {onBack && (
          <button onClick={onBack} className="p-1 -ml-1 rounded-full" style={{ color: T.teal }}>
            <ChevronLeft size={22} />
          </button>
        )}
        <h1 className="truncate" style={{ fontFamily: "Newsreader", fontSize: 18, fontWeight: 600, color: T.ink }}>{title}</h1>
      </div>
      {right}
    </div>
  );
}

function TabBar({ active, onChange }) {
  const T = useT();
  const tabs = [
    { key: "index", label: "Index", icon: BookOpen },
    { key: "favorites", label: "Favorites", icon: Heart },
    { key: "myAyahs", label: "My Ayahs", icon: Layers },
    { key: "profile", label: "Profile", icon: User },
  ];
  return (
    <div className="flex shrink-0" style={{ height: 64, background: T.paper, borderTop: `1px solid ${T.line}` }}>
      {tabs.map((t) => {
        const Icon = t.icon;
        const isActive = active === t.key;
        return (
          <button key={t.key} onClick={() => onChange(t.key)} className="flex-1 flex flex-col items-center justify-center gap-1">
            <Icon size={20} color={isActive ? T.teal : T.inkSoft} strokeWidth={isActive ? 2.4 : 1.8} />
            <span style={{ fontFamily: "Inter", fontSize: 11, fontWeight: isActive ? 600 : 400, color: isActive ? T.teal : T.inkSoft }}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

function Pill({ children, tone = "teal" }) {
  const T = useT();
  const map = { teal: [T.tealSoft, T.teal], gold: [T.goldSoft, T.gold], rose: [T.roseSoft, T.rose] };
  const [bg, fg] = map[tone] || map.teal;
  return (
    <span className="px-2 py-0.5 rounded-full inline-flex items-center gap-1" style={{ background: bg, color: fg, fontFamily: "Inter", fontSize: 11, fontWeight: 600 }}>
      {children}
    </span>
  );
}

function SectionLabel({ children, right }) {
  const T = useT();
  return (
    <div className="flex items-center justify-between mb-2">
      <div style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: T.inkSoft, letterSpacing: 0.4 }}>{children}</div>
      {right}
    </div>
  );
}

function AyahMarker({ number, size = 26 }) {
  const T = useT();
  return (
    <span className="relative inline-flex items-center justify-center shrink-0" style={{ width: size, height: size }}>
      <svg width={size} height={size} viewBox="0 0 30 30" style={{ position: "absolute", inset: 0 }}>
        <polygon
          points="15,1 18,6 24,3 23,10 29,12 24,16 27,22 20,20 18,27 15,22 12,27 10,20 3,22 6,16 1,12 7,10 6,3 12,6"
          fill="none" stroke={T.gold} strokeWidth="1.1"
        />
      </svg>
      <span style={{ fontFamily: "Amiri", fontSize: size * 0.4, color: T.gold, fontWeight: 700, position: "relative" }}>
        {arabicDigits(number)}
      </span>
    </span>
  );
}

function ArabicLine({ words, highlights = [], diffIndex = null, size = 22, endMarker = null }) {
  const T = useT();
  return (
    <div dir="rtl" className="flex flex-wrap items-center gap-x-2 gap-y-2 justify-start">
      {words.map((w, i) => {
        const idx = i + 1;
        const region = highlights.find((h) => idx >= h.from && idx <= h.to);
        const isDiff = diffIndex === idx;
        return (
          <span
            key={i}
            style={{
              fontFamily: "Amiri", fontSize: size, color: T.ink,
              background: region ? region.bg : "transparent",
              borderRadius: region ? 6 : 0,
              padding: region ? "1px 4px" : 0,
              fontWeight: region ? 700 : 400,
              borderBottom: isDiff ? `3px solid ${T.danger}` : "none",
            }}
          >
            {w}
          </span>
        );
      })}
      {endMarker != null && <AyahMarker number={endMarker} size={size * 1.1} />}
    </div>
  );
}

function AudioPlayButton() {
  const T = useT();
  const [playing, setPlaying] = useState(false);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    if (!playing) return;
    const t = setInterval(() => {
      setProgress((p) => {
        if (p >= 100) { setPlaying(false); return 0; }
        return p + 4;
      });
    }, 100);
    return () => clearInterval(t);
  }, [playing]);

  return (
    <div className="flex items-center gap-2">
      <button
        onClick={() => setPlaying((p) => !p)}
        className="flex items-center justify-center rounded-full"
        style={{ width: 26, height: 26, background: T.tealSoft, color: T.teal }}
      >
        {playing ? <Pause size={13} /> : <Play size={13} style={{ marginLeft: 1 }} />}
      </button>
      <div className="rounded-full overflow-hidden" style={{ width: 40, height: 3, background: T.line }}>
        <div style={{ width: `${progress}%`, height: "100%", background: T.teal, transition: "width .1s linear" }} />
      </div>
    </div>
  );
}

function ShareNoteButton({ text }) {
  const T = useT();
  const [copied, setCopied] = useState(false);
  if (!text) return null;
  const copy = () => {
    if (navigator.clipboard) navigator.clipboard.writeText(text).catch(() => {});
    setCopied(true);
    setTimeout(() => setCopied(false), 1500);
  };
  return (
    <button onClick={copy} className="flex items-center gap-1">
      {copied ? <Check size={13} color={T.teal} /> : <Share2 size={13} color={T.inkSoft} />}
      <span style={{ fontFamily: "Inter", fontSize: 11.5, color: copied ? T.teal : T.inkSoft, fontWeight: 600 }}>
        {copied ? "Copied" : "Share"}
      </span>
    </button>
  );
}

function Toast({ toast, onClose }) {
  const T = useT();
  if (!toast) return null;
  return (
    <div
      className="absolute left-4 right-4 flex items-center justify-between rounded-xl px-3.5 py-3"
      style={{ bottom: 76, background: T.ink, boxShadow: "0 10px 24px -8px rgba(0,0,0,0.35)" }}
    >
      <span style={{ fontFamily: "Inter", fontSize: 13, color: T.paper }}>{toast.message}</span>
      {toast.onUndo && (
        <button
          onClick={() => { toast.onUndo(); onClose(); }}
          style={{ fontFamily: "Inter", fontSize: 13, fontWeight: 700, color: T.gold }}
        >
          Undo
        </button>
      )}
    </div>
  );
}

function ConfirmDialog({ title, message, confirmLabel, onCancel, onConfirm }) {
  const T = useT();
  return (
    <div className="absolute inset-0 flex items-end" style={{ background: "rgba(0,0,0,0.4)" }} onClick={onCancel}>
      <div className="w-full rounded-t-3xl p-5" style={{ background: T.cardBg }} onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center gap-2 mb-2">
          <AlertTriangle size={16} color={T.danger} />
          <span style={{ fontFamily: "Newsreader", fontSize: 16, fontWeight: 600, color: T.ink }}>{title}</span>
        </div>
        <p style={{ fontFamily: "Inter", fontSize: 13.5, color: T.inkSoft, marginBottom: 16 }}>{message}</p>
        <div className="flex gap-3">
          <button onClick={onCancel} className="flex-1 py-2.5 rounded-xl" style={{ border: `1px solid ${T.line}`, color: T.ink, fontFamily: "Inter", fontWeight: 600 }}>Cancel</button>
          <button onClick={onConfirm} className="flex-1 py-2.5 rounded-xl" style={{ background: T.danger, color: "#fff", fontFamily: "Inter", fontWeight: 600 }}>{confirmLabel}</button>
        </div>
      </div>
    </div>
  );
}

function AyahDetailScreen({ surah, ayah, onBack, favorites, toggleFavorite, onOpenPhrase }) {
  const T = useT();
  const key = `${surah}:${ayah}`;
  const data = AYAH_WORDS[key];
  const isFav = favorites.some((f) => f.surah === surah && f.ayah === ayah);
  const [noteOpen, setNoteOpen] = useState(false);
  const [note, setNote] = useState("");
  const [activePhraseId, setActivePhraseId] = useState(null);

  if (!data) {
    return (
      <>
        <TopBar title={`Ayah ${surah}:${ayah}`} onBack={onBack} />
        <div className="p-4" style={{ color: T.inkSoft, fontFamily: "Inter" }}>(demo data not included for this ayah)</div>
      </>
    );
  }

  const visiblePhrases = data.phrases.filter((p) => !activePhraseId || p.id === activePhraseId);
  const highlights = visiblePhrases.map((p) => ({ from: p.from, to: p.to, bg: colorTone(T, p.color).soft }));

  return (
    <>
      <TopBar
        title={`Surah ${surah} — Ayah ${ayah}`}
        onBack={onBack}
        right={
          <button onClick={() => toggleFavorite(surah, ayah)}>
            <Heart size={22} color={T.danger} fill={isFav ? T.danger : "none"} strokeWidth={1.8} />
          </button>
        }
      />
      <div className="flex-1 overflow-y-auto px-4 py-5" style={{ background: T.paper }}>
        <div className="rounded-2xl p-4 mb-5" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
          <ArabicLine words={data.words} highlights={highlights} endMarker={data.endMarker} />
        </div>

        <SectionLabel>SIMILAR PHRASES FOUND HERE ({data.phrases.length})</SectionLabel>
        <div className="mb-5 flex flex-col gap-2">
          {data.phrases.map((p) => {
            const tone = colorTone(T, p.color);
            const isActive = activePhraseId === p.id;
            return (
              <button
                key={p.id}
                onClick={() => onOpenPhrase(p.id)}
                className="w-full flex items-center justify-between rounded-xl p-3"
                style={{ background: isActive ? tone.soft : T.cardBg, border: `1px solid ${isActive ? tone.strong : T.line}` }}
              >
                <div className="flex items-center gap-2.5">
                  <span
                    onClick={(e) => { e.stopPropagation(); setActivePhraseId(isActive ? null : p.id); }}
                    role="button"
                    aria-label="Isolate this phrase"
                    className="rounded-full shrink-0"
                    style={{ width: 14, height: 14, background: tone.strong, boxShadow: isActive ? `0 0 0 3px ${tone.soft}` : "none" }}
                  />
                  <span style={{ fontFamily: "Inter", fontSize: 13.5, color: T.ink, fontWeight: 500 }}>
                    Phrase #{p.id} — {p.occurrences} occurrences
                  </span>
                </div>
                <ChevronRight size={16} color={T.inkSoft} />
              </button>
            );
          })}
        </div>
        {data.phrases.length > 1 && (
          <p style={{ fontFamily: "Inter", fontSize: 11.5, color: T.inkSoft, marginTop: -12, marginBottom: 20 }}>
            Tap a colored dot to isolate that phrase in the ayah above.
          </p>
        )}

        <SectionLabel>MNEMONIC</SectionLabel>
        <div className="rounded-xl p-3 mb-4" style={{ background: T.goldSoft, border: `1px solid ${T.gold}33` }}>
          <p style={{ fontFamily: "Inter", fontSize: 13.5, color: T.ink, lineHeight: 1.5 }}>{SYSTEM_TIP}</p>
        </div>

        <SectionLabel right={<ShareNoteButton text={note} />}>MY NOTE</SectionLabel>
        {!noteOpen && !note && (
          <button onClick={() => setNoteOpen(true)} className="w-full flex items-center gap-2 rounded-xl p-3 justify-center" style={{ border: `1.5px dashed ${T.line}` }}>
            <Plus size={16} color={T.inkSoft} />
            <span style={{ fontFamily: "Inter", fontSize: 13.5, color: T.inkSoft }}>Add your own mnemonic</span>
          </button>
        )}
        {(noteOpen || note) && (
          <div className="rounded-xl p-3" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
            <textarea
              autoFocus={noteOpen && !note}
              value={note}
              onChange={(e) => setNote(e.target.value)}
              placeholder="e.g. this one has the shorter ending..."
              className="w-full resize-none outline-none"
              rows={3}
              style={{ fontFamily: "Inter", fontSize: 13.5, color: T.ink, background: "transparent" }}
            />
          </div>
        )}
      </div>
    </>
  );
}

function PhraseComparisonScreen({ phraseId, onBack }) {
  const T = useT();
  return (
    <>
      <TopBar title={`Phrase #${phraseId} — Comparison`} onBack={onBack} />
      <div className="flex-1 overflow-y-auto px-4 py-4" style={{ background: T.paper }}>
        <div className="rounded-xl p-3 mb-4" style={{ background: T.goldSoft, border: `1px solid ${T.gold}33` }}>
          <p style={{ fontFamily: "Inter", fontSize: 13.5, color: T.ink, lineHeight: 1.5 }}>{SYSTEM_TIP}</p>
        </div>
        <p style={{ fontFamily: "Inter", fontSize: 11.5, color: T.inkSoft, marginBottom: 12 }}>
          The underlined word is the one that differs between occurrences.
        </p>
        {PHRASE_OCCURRENCES.map((o, i) => (
          <div key={i} className="rounded-2xl p-4 mb-3" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
            <div className="flex items-center justify-between mb-3">
              <Pill>{o.surah}:{o.ayah}</Pill>
              <AudioPlayButton />
            </div>
            <ArabicLine
              words={o.words}
              highlights={[{ from: 1, to: o.words.length, bg: T.goldSoft }]}
              diffIndex={o.diffAt}
              size={19}
            />
          </div>
        ))}
      </div>
    </>
  );
}

function IndexTab({ favorites, toggleFavorite }) {
  const T = useT();
  const [indexMode, setIndexMode] = useState("surahs");
  const [view, setView] = useState("surahs");
  const [query, setQuery] = useState("");
  const [surah, setSurah] = useState(null);
  const [ayah, setAyah] = useState(null);
  const [phraseId, setPhraseId] = useState(null);
  const [phraseEntry, setPhraseEntry] = useState("fromAyah");

  const filteredSurahs = SURAHS.filter((s) => s.ar.includes(query) || s.en.toLowerCase().includes(query.toLowerCase()));

  if (view === "phrase") {
    return (
      <PhraseComparisonScreen
        phraseId={phraseId}
        onBack={() => setView(phraseEntry === "fromBrowse" ? "surahs" : "detail")}
      />
    );
  }
  if (view === "detail") {
    return (
      <AyahDetailScreen
        surah={surah} ayah={ayah} favorites={favorites} toggleFavorite={toggleFavorite}
        onBack={() => setView("ayahs")}
        onOpenPhrase={(pid) => { setPhraseId(pid); setPhraseEntry("fromAyah"); setView("phrase"); }}
      />
    );
  }
  if (view === "ayahs") {
    const list = AYAHS_BY_SURAH[surah] || [];
    const s = SURAHS.find((x) => x.id === surah);
    return (
      <>
        <TopBar title={`${s.ar}  ·  ${s.en}`} onBack={() => setView("surahs")} />
        <div className="flex-1 overflow-y-auto" style={{ background: T.paper }}>
          {list.map((a) => (
            <button
              key={a.ayah}
              onClick={() => { setAyah(a.ayah); setView("detail"); }}
              className="w-full flex items-start gap-3 px-4 py-3 text-left"
              style={{ borderBottom: `1px solid ${T.line}` }}
            >
              <AyahMarker number={a.ayah} />
              <span dir="rtl" style={{ fontFamily: "Amiri", fontSize: 19, color: T.ink, lineHeight: 1.7 }}>{a.text}</span>
            </button>
          ))}
        </div>
      </>
    );
  }

  return (
    <>
      <TopBar title="Mutashabihat Companion" />
      <div className="px-4 pt-3 pb-2" style={{ background: T.paper }}>
        <div className="flex rounded-xl p-1 mb-3" style={{ background: T.tealSoft }}>
          {[
            { key: "surahs", label: "Surahs" },
            { key: "confusable", label: "Most Confusable" },
          ].map((seg) => (
            <button
              key={seg.key}
              onClick={() => setIndexMode(seg.key)}
              className="flex-1 py-1.5 rounded-lg"
              style={{
                background: indexMode === seg.key ? T.cardBg : "transparent",
                fontFamily: "Inter", fontSize: 12.5, fontWeight: 600,
                color: indexMode === seg.key ? T.teal : T.inkSoft,
              }}
            >
              {seg.label}
            </button>
          ))}
        </div>
        {indexMode === "surahs" && (
          <div className="flex items-center gap-2 px-3 rounded-xl" style={{ background: T.cardBg, border: `1px solid ${T.line}`, height: 40 }}>
            <Search size={16} color={T.inkSoft} />
            <input
              value={query} onChange={(e) => setQuery(e.target.value)}
              placeholder="Search surah name..."
              className="flex-1 outline-none bg-transparent"
              style={{ fontFamily: "Inter", fontSize: 14, color: T.ink }}
            />
          </div>
        )}
      </div>

      <div className="flex-1 overflow-y-auto" style={{ background: T.paper }}>
        {indexMode === "surahs" && filteredSurahs.map((s) => (
          <button
            key={s.id}
            onClick={() => { setSurah(s.id); setView("ayahs"); }}
            className="w-full flex items-center justify-between px-4 py-3"
            style={{ borderBottom: `1px solid ${T.line}` }}
          >
            <div className="flex items-center gap-3">
              <span className="flex items-center justify-center rounded-full shrink-0" style={{ width: 30, height: 30, background: T.tealSoft, color: T.teal, fontFamily: "Inter", fontSize: 12, fontWeight: 700 }}>{s.id}</span>
              <div className="text-left">
                <div style={{ fontFamily: "Amiri", fontSize: 18, color: T.ink }}>{s.ar}</div>
                <div style={{ fontFamily: "Inter", fontSize: 12.5, color: T.inkSoft }}>{s.en}</div>
              </div>
            </div>
            <Pill>{s.count} ayahs</Pill>
          </button>
        ))}

        {indexMode === "confusable" && MOCK_PHRASES.map((p) => (
          <button
            key={p.id}
            onClick={() => { setPhraseId(p.id); setPhraseEntry("fromBrowse"); setView("phrase"); }}
            className="w-full flex items-center justify-between px-4 py-3"
            style={{ borderBottom: `1px solid ${T.line}` }}
          >
            <div className="flex items-center gap-3 min-w-0">
              <span className="flex items-center justify-center rounded-full shrink-0" style={{ width: 24, height: 24, background: T.goldSoft, color: T.gold }}>
                <Flame size={12} />
              </span>
              <div className="text-left min-w-0">
                <div dir="rtl" className="truncate" style={{ fontFamily: "Amiri", fontSize: 16, color: T.ink }}>{p.sample}</div>
                <div style={{ fontFamily: "Inter", fontSize: 11.5, color: T.inkSoft }}>Phrase #{p.id} · {p.surahCount} surahs</div>
              </div>
            </div>
            <Pill tone="gold">{p.occurrenceCount}×</Pill>
          </button>
        ))}
      </div>
    </>
  );
}

function TestMode({ mode, items, onExit }) {
  const T = useT();
  const [i, setI] = useState(0);
  const [selected, setSelected] = useState(null);
  const [revealed, setRevealed] = useState(false);
  const [results, setResults] = useState([]);
  const [confirmExit, setConfirmExit] = useState(false);
  const total = items.length;
  const done = i >= total;

  if (done) {
    const correct = results.filter(Boolean).length;
    return (
      <>
        <TopBar title="Session complete" onBack={onExit} />
        <div className="flex-1 flex flex-col items-center justify-center px-6 text-center" style={{ background: T.paper }}>
          <div className="rounded-full flex items-center justify-center mb-4" style={{ width: 84, height: 84, background: T.tealSoft }}>
            <span style={{ fontFamily: "Newsreader", fontSize: 26, fontWeight: 600, color: T.teal }}>{correct}/{total}</span>
          </div>
          <p style={{ fontFamily: "Inter", fontSize: 14, color: T.inkSoft, marginBottom: 20 }}>
            {correct === total ? "Perfect run — all clear." : "The missed ones will come back sooner next time."}
          </p>
          <button onClick={onExit} className="px-5 py-2.5 rounded-xl" style={{ background: T.teal, color: T.paper, fontFamily: "Inter", fontSize: 14, fontWeight: 600 }}>Done</button>
        </div>
      </>
    );
  }

  const item = items[i];
  const next = (wasCorrect) => {
    setResults((r) => [...r, wasCorrect]);
    setSelected(null);
    setRevealed(false);
    setI((x) => x + 1);
  };

  return (
    <div className="relative flex flex-col flex-1 min-h-0">
      <TopBar title={`Question ${i + 1} of ${total}`} onBack={() => setConfirmExit(true)} />
      <div className="px-4 pt-3" style={{ background: T.paper }}>
        <div className="w-full rounded-full overflow-hidden" style={{ height: 5, background: T.line }}>
          <div className="h-full rounded-full" style={{ width: `${(i / total) * 100}%`, background: T.gold, transition: "width .3s" }} />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-5" style={{ background: T.paper }}>
        {mode === "mcq" && (
          <>
            <div className="rounded-2xl p-4 mb-5" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: T.inkSoft, marginBottom: 8 }}>{item.surah}:{item.ayah}</div>
              <ArabicLine words={item.stem.split(" ")} size={19} />
            </div>
            <SectionLabel>WHICH ENDING BELONGS HERE?</SectionLabel>
            {item.choices.map((c, ci) => {
              const isSelected = selected === ci;
              const isCorrect = ci === item.correctIndex;
              const showState = selected !== null;
              let border = T.line, bg = T.cardBg;
              if (showState && isSelected) { border = isCorrect ? T.teal : T.danger; bg = isCorrect ? T.tealSoft : T.dangerSoft; }
              return (
                <button
                  key={ci} disabled={selected !== null} onClick={() => setSelected(ci)}
                  className="w-full rounded-xl p-3 mb-2 text-left flex items-center justify-between"
                  style={{ background: bg, border: `1.5px solid ${border}` }}
                >
                  <span dir="rtl" style={{ fontFamily: "Amiri", fontSize: 17, color: T.ink }}>{c}</span>
                  {showState && isSelected && (isCorrect ? <Check size={18} color={T.teal} /> : <X size={18} color={T.danger} />)}
                </button>
              );
            })}
            {selected !== null && (
              <button onClick={() => next(selected === item.correctIndex)} className="w-full mt-3 py-3 rounded-xl" style={{ background: T.teal, color: T.paper, fontFamily: "Inter", fontWeight: 600 }}>
                {i + 1 === total ? "Finish" : "Next"}
              </button>
            )}
          </>
        )}

        {mode === "flashcard" && (
          <>
            <div className="flex items-center gap-2 mb-2">
              {!revealed && <EyeOff size={13} color={T.inkSoft} />}
              <SectionLabel>{revealed ? "FULL AYAH" : "HINT — RECALL THE REST"}</SectionLabel>
            </div>
            <div className="rounded-2xl p-4 mb-5" style={{ background: T.cardBg, border: revealed ? `1px solid ${T.line}` : `1.5px dashed ${T.line}` }}>
              <div style={{ fontFamily: "Inter", fontSize: 12, color: T.inkSoft, marginBottom: 8 }}>{item.surah}:{item.ayah}</div>
              {!revealed ? (
                <div dir="rtl" className="flex flex-wrap items-baseline gap-x-2">
                  <ArabicLine words={item.hintWords} size={20} />
                  <span style={{ fontFamily: "Amiri", fontSize: 20, color: T.inkSoft }}>· · ·</span>
                </div>
              ) : (
                <ArabicLine words={item.fullWords} size={20} />
              )}
            </div>
            {!revealed ? (
              <button onClick={() => setRevealed(true)} className="w-full py-3 rounded-xl mb-3 flex items-center justify-center gap-2" style={{ border: `1.5px solid ${T.teal}`, color: T.teal, fontFamily: "Inter", fontWeight: 600 }}>
                Reveal full ayah
              </button>
            ) : (
              <div className="flex gap-3">
                <button onClick={() => next(false)} className="flex-1 py-3 rounded-xl flex items-center justify-center gap-1.5" style={{ background: T.dangerSoft, color: T.danger, fontFamily: "Inter", fontWeight: 600 }}><X size={16} /> Missed it</button>
                <button onClick={() => next(true)} className="flex-1 py-3 rounded-xl flex items-center justify-center gap-1.5" style={{ background: T.tealSoft, color: T.teal, fontFamily: "Inter", fontWeight: 600 }}><Check size={16} /> Got it</button>
              </div>
            )}
          </>
        )}
      </div>

      {confirmExit && (
        <ConfirmDialog
          title="Leave this session?"
          message={`You're on question ${i + 1} of ${total}. Progress for this session won't be saved.`}
          confirmLabel="Leave"
          onCancel={() => setConfirmExit(false)}
          onConfirm={onExit}
        />
      )}
    </div>
  );
}

function FavoritesTab({ favorites, toggleFavorite, showToast }) {
  const T = useT();
  const [view, setView] = useState("list");
  const [surah, setSurah] = useState(null);
  const [ayah, setAyah] = useState(null);
  const [phraseId, setPhraseId] = useState(null);

  const testItems = [
    {
      surah: 2, ayah: 112,
      stem: "بَلَىٰ مَنْ أَسْلَمَ وَجْهَهُۥ لِلَّهِ وَهُوَ مُحْسِنٌ فَلَهُۥٓ أَجْرُهُۥ عِندَ رَبِّهِۦ ___",
      choices: [
        "وَلَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ",
        "فَلَا خَوْفٌ عَلَيْهِمْ وَلَا هُمْ يَحْزَنُونَ",
        "وَلَا خَوْفٌ عَلَيْهِمْ وَهُمْ لَا يَحْزَنُونَ",
        "فَلَا خَوْفٌ عَلَيْهِمْ وَهُمْ لَا يَحْزَنُونَ",
      ],
      correctIndex: 0,
    },
  ];

  if (view === "phrase") return <PhraseComparisonScreen phraseId={phraseId} onBack={() => setView("detail")} />;
  if (view === "detail") {
    return (
      <AyahDetailScreen
        surah={surah} ayah={ayah} favorites={favorites} toggleFavorite={toggleFavorite}
        onBack={() => setView("list")}
        onOpenPhrase={(pid) => { setPhraseId(pid); setView("phrase"); }}
      />
    );
  }
  if (view === "test") return <TestMode mode="mcq" items={testItems} onExit={() => setView("list")} />;

  return (
    <>
      <TopBar title="Favorites" />
      <div className="flex-1 overflow-y-auto px-4 py-4" style={{ background: T.paper }}>
        {favorites.length === 0 && (
          <p style={{ fontFamily: "Inter", fontSize: 13.5, color: T.inkSoft, textAlign: "center", marginTop: 40 }}>Tap the heart on any ayah to save it here.</p>
        )}
        {favorites.map((f, idx) => {
          const due = f.lastAttemptedDaysAgo >= 5;
          return (
            <button
              key={idx}
              onClick={() => { setSurah(f.surah); setAyah(f.ayah); setView("detail"); }}
              className="w-full flex items-center justify-between rounded-xl p-3 mb-2"
              style={{ background: T.cardBg, border: `1px solid ${T.line}` }}
            >
              <div className="flex items-center gap-2.5">
                <Heart size={16} color={T.danger} fill={T.danger} />
                <span style={{ fontFamily: "Inter", fontSize: 14, fontWeight: 600, color: T.ink }}>{f.surah}:{f.ayah}</span>
                {due && <Pill tone="gold"><Clock size={10} /> Due</Pill>}
                {f.misses > 0 && <Pill>{f.misses} missed</Pill>}
              </div>
              <span
                role="button"
                aria-label="Remove from favorites"
                onClick={(e) => {
                  e.stopPropagation();
                  toggleFavorite(f.surah, f.ayah);
                  showToast("Removed from Favorites", () => toggleFavorite(f.surah, f.ayah));
                }}
              >
                <ChevronRight size={16} color={T.inkSoft} />
              </span>
            </button>
          );
        })}
        {favorites.length > 0 && (
          <button onClick={() => setView("test")} className="w-full mt-4 py-3 rounded-xl flex items-center justify-center gap-2" style={{ background: T.gold, color: T.paper, fontFamily: "Inter", fontWeight: 600 }}>
            <GraduationCap size={18} /> Start Test Mode
          </button>
        )}
      </div>
    </>
  );
}

function MyAyahDetailScreen({ item, onBack, onDelete, onNoteChange }) {
  const T = useT();
  return (
    <>
      <TopBar title={`Surah ${item.surah} — Ayah ${item.ayah}`} onBack={onBack} right={<button onClick={onDelete}><Trash2 size={19} color={T.inkSoft} /></button>} />
      <div className="flex-1 overflow-y-auto px-4 py-5" style={{ background: T.paper }}>
        <div className="rounded-2xl p-4 mb-5" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
          <ArabicLine words={item.full.split(" ")} size={22} />
        </div>
        <SectionLabel right={<ShareNoteButton text={item.note} />}>MY NOTE</SectionLabel>
        <div className="rounded-xl p-3" style={{ background: T.cardBg, border: `1px solid ${T.line}` }}>
          <textarea
            value={item.note || ""}
            onChange={(e) => onNoteChange(e.target.value)}
            placeholder="Why is this one hard to recall?"
            className="w-full resize-none outline-none"
            rows={3}
            style={{ fontFamily: "Inter", fontSize: 13.5, color: T.ink, background: "transparent" }}
          />
        </div>
      </div>
    </>
  );
}

function MyAyahsTab({ showToast }) {
  const T = useT();
  const [items, setItems] = useState(INITIAL_MY_AYAHS);
  const [view, setView] = useState("list");
  const [query, setQuery] = useState("");
  const [selectedIdx, setSelectedIdx] = useState(null);

  const addResults = query.length > 0
    ? [{ surah: 18, ayah: 10, text: "إِذْ أَوَى ٱلْفِتْيَةُ إِلَى ٱلْكَهْفِ فَقَالُوا۟ رَبَّنَآ ءَاتِنَا مِن لَّدُنكَ رَحْمَةً" }]
    : [];

  const testItems = items.map((it) => {
    const fullWords = it.full.split(" ");
    return { surah: it.surah, ayah: it.ayah, hintWords: fullWords.slice(0, 3), fullWords };
  });

  const removeAt = (idx) => {
    const removed = items[idx];
    setItems((prev) => prev.filter((_, i) => i !== idx));
    showToast("Removed from My Ayahs", () => {
      setItems((prev) => {
        const copy = [...prev];
        copy.splice(idx, 0, removed);
        return copy;
      });
    });
  };

  if (view === "test") return <TestMode mode="flashcard" items={testItems} onExit={() => setView("list")} />;

  if (view === "detail" && selectedIdx !== null) {
    return (
      <MyAyahDetailScreen
        item={items[selectedIdx]}
        onBack={() => { setView("list"); setSelectedIdx(null); }}
        onDelete={() => { removeAt(selectedIdx); setView("list"); setSelectedIdx(null); }}
        onNoteChange={(text) => setItems((prev) => prev.map((it, i) => (i === selectedIdx ? { ...it, note: text } : it)))}
      />
    );
  }

  if (view === "add") {
    return (
      <>
        <TopBar title="Add a difficult ayah" onBack={() => setView("list")} />
        <div className="px-4 pt-3" style={{ background: T.paper }}>
          <div className="flex items-center gap-2 px-3 rounded-xl" style={{ background: T.cardBg, border: `1px solid ${T.line}`, height: 40 }}>
            <Search size={16} color={T.inkSoft} />
            <input
              autoFocus value={query} onChange={(e) => setQuery(e.target.value)}
              placeholder="Search any ayah (surah:ayah or text)..."
              className="flex-1 outline-none bg-transparent"
              style={{ fontFamily: "Inter", fontSize: 14, color: T.ink }}
            />
          </div>
        </div>
        <div className="flex-1 overflow-y-auto px-4 py-3" style={{ background: T.paper }}>
          {addResults.map((r, i) => (
            <button
              key={i}
              onClick={() => {
                setItems((prev) => [...prev, { surah: r.surah, ayah: r.ayah, note: "", full: r.text }]);
                setView("list"); setQuery("");
              }}
              className="w-full flex items-center justify-between rounded-xl p-3 mb-2"
              style={{ background: T.cardBg, border: `1px solid ${T.line}` }}
            >
              <div className="text-left">
                <div style={{ fontFamily: "Inter", fontSize: 12, color: T.inkSoft, marginBottom: 2 }}>{r.surah}:{r.ayah}</div>
                <div dir="rtl" style={{ fontFamily: "Amiri", fontSize: 17, color: T.ink }}>{r.text}</div>
              </div>
              <Plus size={18} color={T.teal} />
            </button>
          ))}
        </div>
      </>
    );
  }

  return (
    <>
      <TopBar title="My Ayahs" right={<button onClick={() => setView("add")}><Plus size={22} color={T.teal} /></button>} />
      <div className="flex-1 overflow-y-auto px-4 py-4" style={{ background: T.paper }}>
        {items.length === 0 && (
          <p style={{ fontFamily: "Inter", fontSize: 13.5, color: T.inkSoft, textAlign: "center", marginTop: 40 }}>Add ayahs that are hard to recall, whether or not they involve Mutashabihat.</p>
        )}
        {items.map((it, idx) => (
          <button
            key={idx}
            onClick={() => { setSelectedIdx(idx); setView("detail"); }}
            className="w-full flex items-center justify-between rounded-xl p-3 mb-2 text-left"
            style={{ background: T.cardBg, border: `1px solid ${T.line}` }}
          >
            <div>
              <div style={{ fontFamily: "Inter", fontSize: 14, fontWeight: 600, color: T.ink }}>{it.surah}:{it.ayah}</div>
              {it.note && <div style={{ fontFamily: "Inter", fontSize: 12, color: T.inkSoft, marginTop: 2 }}>{it.note}</div>}
            </div>
            <div className="flex items-center gap-3">
              <span role="button" aria-label="Delete" onClick={(e) => { e.stopPropagation(); removeAt(idx); }}>
                <Trash2 size={16} color={T.inkSoft} />
              </span>
              <ChevronRight size={15} color={T.inkSoft} />
            </div>
          </button>
        ))}
        {items.length > 0 && (
          <button onClick={() => setView("test")} className="w-full mt-4 py-3 rounded-xl flex items-center justify-center gap-2" style={{ background: T.gold, color: T.paper, fontFamily: "Inter", fontWeight: 600 }}>
            <GraduationCap size={18} /> Start Test Mode
          </button>
        )}
      </div>
    </>
  );
}

function ProfileTab({ dark, setDark }) {
  const T = useT();
  const [fontSize, setFontSize] = useState(1);

  const Row = ({ icon: Icon, label, right }) => (
    <div className="flex items-center justify-between px-4 py-3.5" style={{ borderBottom: `1px solid ${T.line}` }}>
      <div className="flex items-center gap-3">
        <Icon size={18} color={T.teal} />
        <span style={{ fontFamily: "Inter", fontSize: 14.5, color: T.ink }}>{label}</span>
      </div>
      {right}
    </div>
  );

  return (
    <>
      <TopBar title="Profile" />
      <div className="flex-1 overflow-y-auto" style={{ background: T.paper }}>
        <div className="flex items-center gap-4 px-4 py-5">
          <div className="rounded-full flex items-center justify-center" style={{ width: 56, height: 56, background: T.tealSoft }}>
            <span style={{ fontFamily: "Newsreader", fontSize: 20, fontWeight: 600, color: T.teal }}>2</span>
          </div>
          <div>
            <div style={{ fontFamily: "Inter", fontSize: 12.5, color: T.inkSoft }}>Favorites</div>
            <div style={{ fontFamily: "Newsreader", fontSize: 20, fontWeight: 600, color: T.ink }}>2 ayahs saved</div>
          </div>
        </div>

        <div className="px-4 pt-2 pb-1" style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: T.inkSoft, letterSpacing: 0.5 }}>APPEARANCE</div>
        <Row
          icon={dark ? Moon : Sun} label="Dark mode"
          right={
            <button onClick={() => setDark((d) => !d)} className="rounded-full relative" style={{ width: 40, height: 22, background: dark ? T.teal : T.line }}>
              <span className="absolute rounded-full" style={{ width: 18, height: 18, top: 2, left: dark ? 20 : 2, transition: "left .15s", background: T.cardBg }} />
            </button>
          }
        />
        <Row
          icon={TypeIcon} label="Arabic text size"
          right={
            <div className="flex gap-1">
              {["A", "A", "A"].map((a, i) => (
                <button key={i} onClick={() => setFontSize(i)} className="rounded-lg flex items-center justify-center" style={{ width: 26, height: 26, background: fontSize === i ? T.tealSoft : "transparent", color: fontSize === i ? T.teal : T.inkSoft, fontSize: 11 + i * 2, fontFamily: "Inter", fontWeight: 600 }}>{a}</button>
              ))}
            </div>
          }
        />

        <div className="px-4 pt-4 pb-1" style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: T.inkSoft, letterSpacing: 0.5 }}>CONFIDENCE BY SURAH</div>
        <div className="px-4 py-2">
          {CONFIDENCE.map((c) => (
            <div key={c.surah} className="mb-3">
              <div className="flex items-center justify-between mb-1">
                <span style={{ fontFamily: "Inter", fontSize: 12.5, color: T.ink }}>{c.surah}. {c.en}</span>
                <span style={{ fontFamily: "Inter", fontSize: 12, color: T.inkSoft }}>{c.pct}%</span>
              </div>
              <div className="rounded-full overflow-hidden" style={{ height: 6, background: T.line }}>
                <div style={{ width: `${c.pct}%`, height: "100%", background: T.teal }} />
              </div>
            </div>
          ))}
        </div>

        <div className="px-4 pt-3 pb-1" style={{ fontFamily: "Inter", fontSize: 12, fontWeight: 700, color: T.inkSoft, letterSpacing: 0.5 }}>PROGRESS</div>
        <Row icon={RotateCcw} label="Reset test history" right={<ChevronRight size={16} color={T.inkSoft} />} />
        <Row icon={Settings} label="About this app" right={<ChevronRight size={16} color={T.inkSoft} />} />
      </div>
    </>
  );
}

export default function MutashabihatMockup() {
  const [tab, setTab] = useState("index");
  const [dark, setDark] = useState(false);
  const [favorites, setFavorites] = useState(INITIAL_FAVORITES);
  const [toast, setToast] = useState(null);
  const theme = dark ? DARK : LIGHT;

  useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 4000);
    return () => clearTimeout(t);
  }, [toast]);

  const showToast = (message, onUndo) => setToast({ message, onUndo });

  const toggleFavorite = (surah, ayah) => {
    setFavorites((prev) => {
      const exists = prev.some((f) => f.surah === surah && f.ayah === ayah);
      if (exists) return prev.filter((f) => !(f.surah === surah && f.ayah === ayah));
      return [...prev, { surah, ayah, misses: 0, lastAttemptedDaysAgo: 0 }];
    });
  };

  return (
    <ThemeContext.Provider value={theme}>
      <div className="w-full min-h-screen flex items-center justify-center p-8" style={{ background: theme.paperDeep }}>
        <style>{fontImport}</style>
        <div
          className="relative flex flex-col overflow-hidden"
          style={{ width: 390, height: 780, borderRadius: 40, border: `10px solid ${theme.frame}`, boxShadow: dark ? "0 30px 60px -20px rgba(0,0,0,0.6)" : "0 30px 60px -20px rgba(15,40,35,0.35)" }}
        >
          {tab === "index" && <IndexTab favorites={favorites} toggleFavorite={toggleFavorite} />}
          {tab === "favorites" && <FavoritesTab favorites={favorites} toggleFavorite={toggleFavorite} showToast={showToast} />}
          {tab === "myAyahs" && <MyAyahsTab showToast={showToast} />}
          {tab === "profile" && <ProfileTab dark={dark} setDark={setDark} />}
          <TabBar active={tab} onChange={setTab} />
          <Toast toast={toast} onClose={() => setToast(null)} />
        </div>
      </div>
    </ThemeContext.Provider>
  );
}
