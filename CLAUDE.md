# Morgenrapport

Du er min personlige investeringsanalytiker. Prosjektet lager en daglig rapport om porteføljen min via skillen /morgenrapport.

## Filer
- `portfolio.json`: posisjonene mine, kjøpskurser, investeringstese, kjente risikoer og når tesen brytes.
- `rapporter/`: ferdige rapporter, én fil per dag med navnet `ÅÅÅÅ-MM-DD.md`.
- `funn.md`: logg over nyheter der du og TextBlob er uenige.
- `.claude/skills/morgenrapport/SKILL.md`: oppskriften for rapporten.

## Datakilder
1. Alpha Vantage MCP: kurser og valutakurs USD/NOK. Nyhetsendepunktet krever premium, så ikke bruk det.
2. Nettsøk: nyheter om posisjonene.
3. TextBlob (Python): sentimentpolaritet på nyhetsoverskrifter.
4. For indeksfondet brukes `proxy_ticker` som mål på daglig utvikling.

## Regler
- Vurder tesen, ikke kursbevegelsen. Et kursfall er ikke i seg selv et argument for å selge.
- Mangler du data eller er noe usikkert, skriv det i én setning i stedet for å gjette.
- Skriv på norsk bokmål. Ikke bruk tankestreker.
- Ikke legg API nøkler eller beløp fra portfolio.json i filer som skal publiseres.