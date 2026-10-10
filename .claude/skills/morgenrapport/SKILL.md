---
name: morgenrapport
description: Lager dagens morgenrapport om porteføljen min basert på portfolio.json, og lagrer den i rapporter/. Bruk når jeg ber om morgenrapport eller dagens rapport.
---

# Morgenrapport

Målet er en rapport jeg kan lese på to minutter og forstå hva som har skjedd og hva jeg bør følge med på.

## Fremgangsmåte
1. Les portfolio.json og forrige rapport i rapporter/.
2. Hent siste sluttkurs for hver posisjon og dagens USD/NOK kurs fra Alpha Vantage. Feiler det, prøv én gang til og skriv det i rapporten hvis det fortsatt feiler.
3. Regn ut verdi i NOK, endring siden forrige handelsdag og total gevinst eller tap. Bruk `kostpris_nok` hvis feltet finnes, ellers kjøpskurs omregnet med dagens valutakurs.
4. For indeksfondet: bruk `verdi_dato` til å avgjøre hvilken utvikling som allerede er med i `verdi_nok`.
5. Hent nyheter publisert etter forrige rapport. Finnes ingen tidligere rapport, bruk de siste sju dagene. Store nyheter som berører `kjente_risikoer` eller `tesen_brytes_hvis` skal alltid med, selv om de er litt eldre.
6. Kjør TextBlob på hver overskrift.
7. Vurder hver viktige nyhet opp mot `investeringstese`, `kjente_risikoer` og `tesen_brytes_hvis`. Spør: styrker eller svekker dette grunnen til at jeg eier aksjen?
8. Skriv rapporten og lagre den som rapporter/ÅÅÅÅ-MM-DD.md. Finnes filen fra før, overskriv den.
9. Når du er uenig med TextBlob, legg til en linje i funn.md med dato, overskrift, TextBlob sin score, din vurdering og én setning om hvorfor. Ikke legg inn samme overskrift to ganger.
10. Svar med én linje: total verdi i NOK, endring siden forrige handelsdag, og om noe treffer tesen_brytes_hvis.

## Regler for rapporten
- Treffer en nyhet et av punktene i `tesen_brytes_hvis`, marker det tydelig øverst.
- Oppgi TextBlob sin polaritet for hver nyhet, og gi deretter din egen vurdering i finanskontekst. Er dere uenige, forklar kort hvorfor.
- Ikke vis utregninger, bare resultatene.
- Maks rundt 300 ord.

## Rapportformat

# Morgenrapport ÅÅÅÅ-MM-DD

(Hvis en nyhet treffer `tesen_brytes_hvis`: en tydelig advarsel her, før alt annet.)

## Porteføljen
| Posisjon | Kurs | Endring i dag | Verdi NOK | Totalt mot kjøp |
|---|---|---|---|---|
Total verdi og endring i NOK på én linje under tabellen.

## Nyheter
For hver posisjon, maks tre nyheter:
- **Overskrift** (kilde): én setning om hva det betyr, og om det **styrker**, **svekker** eller er **nøytralt** for tesen.
- TextBlob: [polaritet]. Min vurdering: [positiv/negativ/nøytral]. Uenig? Forklar kort hvorfor.

## Følg med i dag
Én konkret ting, for eksempel en resultatlansering, et rentemøte eller en nyhet som kan utvikle seg.

## Påminnelser
- Hvis `kommende_innskudd_nok` er større enn 0, minn meg på å oppdatere portfolio.json når innskuddet er investert.
- Hvis `verdi_dato` er eldre enn sju dager, minn meg på å oppdatere verdien på indeksfondet.