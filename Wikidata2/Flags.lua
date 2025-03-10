local flags = {
    Q805 = "Flag of Yemen.svg", -- YE
    Q16 = "Flag of Canada.svg", -- CAN
    Q17 = "Flag of Japan.svg", -- JPN
    Q20 = "Flag of Norway.svg", -- NOR
    Q27 = "Flag of Ireland.svg", -- IRL
    Q28 = "Flag of Hungary.svg", -- HUN
    Q29 = "Flag of Spain.svg", -- ESP
    Q30 = "Flag of the United States.svg", -- USA
    Q31 = "Flag of Belgium (civil).svg", -- BEL
    Q32 = "Flag of Luxembourg.svg", -- LUX
    Q33 = "Flag of Finland.svg", -- FIN
    Q34 = "Flag of Sweden.svg", -- SWE
    Q35 = "Flag of Denmark.svg", -- DEN
    Q36 = "Flag of Poland.svg", -- POL
    Q37 = "Flag of Lithuania.svg", -- LTU
    Q38 = "Flag of Italy.svg", -- ITA
    Q39 = "Flag of Switzerland.svg", -- SUI
    Q40 = "Flag of Austria.svg", -- AUT
    Q41 = "Flag of Greece.svg", -- GRE
    Q43 = "Flag of Turkey.svg", -- TUR
    Q45 = "Flag of Portugal.svg", -- POR
    Q55 = "Flag of the Netherlands.svg", -- NED
    Q77 = "Flag of Uruguay.svg", -- URU
    Q96 = "Flag of Mexico.svg", -- MEX
    Q114 = "Flag of Kenya.svg", -- KEN
    Q115 = "Flag of Ethiopia.svg", -- ETH
    Q142 = "Flag of France.svg", -- FRA
    Q145 = "Flag of the United Kingdom.svg", -- GBR
    Q148 = "Flag of the People's Republic of China.svg", -- CHN
    Q155 = "Flag of Brazil.svg", -- BRA
    Q159 = "Flag of Russia.svg", -- RUS
    Q183 = "Flag of Germany.svg", -- GER
    Q184 = "Flag of Belarus.svg", -- BLR
    Q189 = "Flag of Iceland.svg", -- ISL
    Q191 = "Flag of Estonia.svg", -- EST
    Q211 = "Flag of Latvia.svg", -- LAT
    Q212 = "Flag of Ukraine.svg", -- UKR
    Q213 = "Flag of the Czech Republic.svg", -- CZE
    Q214 = "Flag of Slovakia.svg", -- SVK
    Q215 = "Flag of Slovenia.svg", -- SLO
    Q217 = "Flag of Moldova.svg", -- MDA
    Q218 = "Flag of Romania.svg", -- ROU
    Q219 = "Flag of Bulgaria.svg", -- BUL
    Q222 = "Flag of Albania.svg", -- ALB
    Q224 = "Flag of Croatia.svg", -- CRO
    Q227 = "Flag of Azerbaijan.svg", -- AZE
    Q228 = "Flag of Andorra.svg", -- AND
    Q229 = "Flag of Cyprus.svg", -- CYP
    Q232 = "Flag of Kazakhstan.svg", -- KAZ
    Q235 = "Flag of Monaco.svg", -- MON
    Q238 = "Flag of San Marino.svg", -- SMR
    Q241 = "Flag of Cuba.svg", -- CUB
    Q252 = "Flag of Indonesia.svg", -- INA
    Q258 = "Flag of South Africa.svg", -- RSA
    Q262 = "Flag of Algeria.svg", -- ALG
    Q265 = "Flag of Uzbekistan.svg", -- UZB
    Q298 = "Flag of Chile.svg", -- CHI
    Q334 = "Flag of Singapore.svg", -- SGP
    Q347 = "Flag of Liechtenstein.svg", -- LIE
    Q398 = "Flag of Bahrain.svg", -- BRN
    Q403 = "Flag of Serbia.svg", -- SRB
    Q408 = "Flag of Australia.svg", -- AUS
    Q414 = "Flag of Argentina.svg", -- ARG
    Q419 = "Flag of Peru.svg", -- PER
    Q664 = "Flag of New Zealand.svg", -- NZL
    Q711 = "Flag of Mongolia.svg", -- MGL
    Q717 = "Flag of Venezuela.svg", -- VEN
    Q733 = "Flag of Paraguay.svg", -- PAR
    Q736 = "Flag of Ecuador.svg", -- ECU
    Q739 = "Flag of Colombia.svg", -- COL
    Q750 = "Flag of Bolivia.svg", -- BOL
    Q754 = "Flag of Trinidad and Tobago.svg", -- TTO
    Q774 = "Flag of Guatemala.svg", -- GUA
    Q778 = "Flag of the Bahamas.svg", -- BAH
    Q783 = "Flag of Honduras.svg", -- HON
    Q786 = "Flag of the Dominican Republic.svg", -- DOM
    Q794 = "Flag of Iran.svg", -- IRI
    Q800 = "Flag of Costa Rica (state).svg", -- CRC
    Q801 = "Flag of Israel.svg", -- ISR
    Q804 = "Flag of Panama.svg", -- PAN
    Q813 = "Flag of Kyrgyzstan.svg", -- KGZ
    Q817 = "Flag of Kuwait.svg", -- KUW
    Q833 = "Flag of Malaysia.svg", -- MAS
    Q842 = "Flag of Oman.svg", -- OMA
    Q846 = "Flag of Qatar.svg", -- QAT
    Q858 = "Flag of the Syrian revolution.svg", -- SYR
    Q865 = "Flag of the Republic of China.svg", -- TPE
    Q869 = "Flag of Thailand.svg", -- THA
    Q878 = "Flag of the United Arab Emirates.svg", -- UAE
    Q881 = "Flag of Vietnam.svg", -- VIE
    Q884 = "Flag of South Korea.svg", -- KOR
    Q916 = "Flag of Angola.svg", -- ANG
    Q921 = "Flag of Brunei.svg", -- BRU
    Q928 = "Flag of the Philippines.svg", -- PHI
    Q948 = "Flag of Tunisia.svg", -- TUN
    Q954 = "Flag of Zimbabwe.svg", -- ZIM
    Q965 = "Flag of Burkina Faso.svg", -- BUR
    Q983 = "Flag of Equatorial Guinea.svg", -- GEQ
    Q986 = "Flag of Eritrea.svg", -- ERI
    Q1000 = "Flag of Gabon.svg", -- GAB
    Q1007 = "Flag of Guinea-Bissau.svg", -- GBS
    Q1008 = "Flag of Côte d'Ivoire.svg", -- CIV
    Q1009 = "Flag of Cameroon.svg", -- CMR
    Q1027 = "Flag of Mauritius.svg", -- MRI
    Q1028 = "Flag of Morocco.svg", -- MAR
    Q1030 = "Flag of Namibia.svg", -- NAM
    Q1036 = "Flag of Uganda.svg", -- UGA
    Q1037 = "Flag of Rwanda.svg", -- RWA
    Q9676 = "Flag of the Isle of Man.svg", -- IMN
    Q15180 = "Flag of the Soviet Union.svg", -- URS
    Q16957 = "Flag of East Germany.svg", -- GDR
    Q8646 = "Flag of Hong Kong.svg", -- HKG
    Q25228 = "Flag of Anguilla.svg", -- AIA
    Q29999 = "Flag of the Netherlands.svg", -- NED
    Q33946 = "Flag of the Czech Republic.svg", -- TCH
    Q36704 = "Flag of Yugoslavia (1992–2003).svg", -- YUG
    Q41304 = "Flag of Germany (3-2 aspect ratio).svg", -- GER
    Q83286 = "Flag of Yugoslavia (1943–1992).svg", -- YUG
    Q172579 = "Flag of Italy (1861–1946).svg", -- ITA
    Q216923 = "Flag of Chinese Taipei for Olympic games.svg", -- TPE
    Q268970 = "Flag of Austria.svg", -- AUT
    Q713750 = "Flag of Germany.svg", -- FRG
    Q853348 = "Flag of the Czech Republic.svg", -- TCH
    Q2415901 = "Merchant flag of Germany (1946–1949).svg", -- GER
    Q13474305 = "Flag of Spain (1945–1977).svg", -- ESP
}
return flags
