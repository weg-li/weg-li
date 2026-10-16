# frozen_string_literal: true

class Owi21Registration
  COUNTRY_CODES = %w[
    AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ
    BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ
    CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ
    DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR
    GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY
    HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP
    KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY
    MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ
    NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY
    QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ
    TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ
    VA VC VE VG VI VN VU WF WS XK YE YT ZA ZM ZW
  ].freeze

  # International vehicle signs differ from ISO alpha-2 codes; unlisted codes are unchanged.
  NATION_CODES = {
    "AD" => "AND",
    "AE" => "UAE",
    "AF" => "AFG",
    "AR" => "RA",
    "AT" => "A",
    "AU" => "AUS",
    "BA" => "BIH",
    "BB" => "BDS",
    "BE" => "B",
    "BH" => "BRN",
    "BI" => "RU",
    "BJ" => "DY",
    "BN" => "BRU",
    "BO" => "BOL",
    "BT" => "BHT",
    "BZ" => "BH",
    "CA" => "CDN",
    "CD" => "CGO",
    "CF" => "RCA",
    "CG" => "RCB",
    "CL" => "RCH",
    "CM" => "CAM",
    "CN" => "CHN",
    "DE" => "D",
    "DJ" => "DJI",
    "DM" => "WD",
    "DO" => "DOM",
    "EE" => "EST",
    "EG" => "ET",
    "ES" => "E",
    "ET" => "ETH",
    "FI" => "FIN",
    "FJ" => "FJI",
    "FR" => "F",
    "GA" => "G",
    "GB" => "UK",
    "GD" => "WG",
    "GG" => "GBG",
    "GI" => "GBZ",
    "GM" => "WAG",
    "GN" => "RG",
    "GT" => "GCA",
    "GW" => "GUB",
    "GY" => "GUY",
    "HU" => "H",
    "ID" => "RI",
    "IE" => "IRL",
    "IM" => "GBM",
    "IN" => "IND",
    "IQ" => "IRQ",
    "IT" => "I",
    "JE" => "GBJ",
    "JM" => "JA",
    "JO" => "HKJ",
    "JP" => "J",
    "KE" => "EAK",
    "KH" => "K",
    "KM" => "COM",
    "KR" => "ROK",
    "KW" => "KWT",
    "LA" => "LAO",
    "LB" => "RL",
    "LC" => "WL",
    "LI" => "FL",
    "LK" => "CL",
    "LR" => "LB",
    "LU" => "L",
    "LY" => "LAR",
    "ME" => "MNE",
    "MG" => "RM",
    "MK" => "NMK",
    "ML" => "RMM",
    "MM" => "BUR",
    "MN" => "MGL",
    "MR" => "RIM",
    "MT" => "M",
    "MU" => "MS",
    "MX" => "MEX",
    "MY" => "MAL",
    "MZ" => "MOC",
    "NA" => "NAM",
    "NE" => "RN",
    "NG" => "WAN",
    "NI" => "NIC",
    "NO" => "N",
    "NP" => "NEP",
    "NR" => "NAU",
    "PG" => "PNG",
    "PH" => "RP",
    "PT" => "P",
    "QA" => "Q",
    "RS" => "SRB",
    "RU" => "RUS",
    "RW" => "RWA",
    "SA" => "KSA",
    "SC" => "SY",
    "SD" => "SUD",
    "SE" => "S",
    "SG" => "SGP",
    "SI" => "SLO",
    "SL" => "WAL",
    "SM" => "RSM",
    "SR" => "SME",
    "SS" => "SSD",
    "ST" => "STP",
    "SV" => "ES",
    "SY" => "SYR",
    "SZ" => "SD",
    "TD" => "TCH",
    "TH" => "T",
    "TW" => "RC",
    "TZ" => "EAT",
    "UG" => "EAU",
    "US" => "USA",
    "VA" => "V",
    "VC" => "WV",
    "VE" => "YV",
    "VG" => "BVI",
    "XK" => "RKS",
    "YE" => "YAR",
    "ZM" => "Z",
  }.freeze

  # Other international vehicle signs are accepted directly as Merkmal by xOWi's value list.
  PLATE_TYPES = { "A" => "2", "NL" => "3", "CH" => "5", "F" => "6" }.freeze

  def self.attributes(registration)
    match = /\A\s*\(([A-Za-z]{2})\)\s+(.+)\z/m.match(registration.to_s)
    match = nil unless match && COUNTRY_CODES.include?(match[1].upcase)
    country, plate = match ? [match[1].upcase, match[2]] : ["DE", registration]
    if country == "DE"
      return { KFZ_Kennzeichen: Vehicle.normalize(plate, text_divider: "-"), KFZ_Kennzeichen_Merkmal: "1" }
    end

    nation = NATION_CODES.fetch(country, country)
    { KFZ_Kennzeichen: plate, KFZ_Kennzeichen_Merkmal: PLATE_TYPES.fetch(nation, nation), KFZ_Kennzeichen_Nation: nation }
  end
end
