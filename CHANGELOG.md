# Changelog Linny.vim

## 0.7.2 - 15 mrt 2023
- add copy document menu action
- set old name in document copy action
- improved level 2 layout
- only action menu for linny documents
- new level-2 mounts
- new level-2 mounts template example in new configuration
- update new configuration template

## 0.7.1 - 5 mar 2023

- new action: set taxonomy
- new action: remove taxonomy
- make ONLY config AND not OR
- replace - for space in GROUP_BY

## 0.7.0 - 17 feb 2023
- fix DIR and FILE wikitags on non macOS machines
- improve help
- use starred taxonomies
- context menu for terms and documents
- archive action for documents (using fred)
- archive action for terms
- open website from locations
- link to linden-project

## 0.6.0 - 2 may 2021
- Comply with **Linden Specification 0.2**
- Complete documentation

## 0.5.5 - 30 december 2020
- force extra space for wikitags

## 0.5.4
- keepalt file fix
- open dir working in Linux

## 0.5.1.5 - 19 feb 2020
- toon open doenitems in linny menu

## 0.5.1.5 - 17 feb 2020
- uitlijning Linny items
- maak WIKITAG DIR
- maak WIKITAG FILE
- fix frontmatter browsers

## Linny.vim 0.5.1.4 - more solving of annoyances
- klein testje met autocomplete views in l2menu
- popup views in l1menu

## Linny.vim 0.5.1.3 - more solving of annoyances

- wikitag LIN ipv LINNY
- shortcut voor LinnyGrep
- allow more only's in l2-config
- Autocomplete bij typen filteren

## Linny.vim 0.5.2.1 - solve annoyances
- klant: v:null oplossing
- linny: ctrl follow link: kopieer nooit de title
- no [az] en [date] by default
- in default config [az] en [date] by default
- <SHIFT-V> terug in views
- starred terms: toon term in lijst
- no view menu when only one view
- toggle markdown list [list, todo, done]
- global shortcuts for starred docs (;s1)
- refactor: more internal variable renaming
- global shortcuts for starred terms (;S1)
- global shortcut for refresh menu
- global shortcut for home menu

## Linny.vim 0.5.2
- Pluginsysteem v1 [[Linny wiki tags]]?
- version version in vader.vim
- overview needed commands

## Linny.vim 0.5.1.1
- Changelog macro
- version in sep file
- release script
- documentation howto release
- Testdata
- Testcase bedenken
- Vader testen
- .travis
- testbadge in readme

## Linny.vim 0.5.0 - ma 20 okt 2019
- terminologie wijzingen doorvoeren, zie Lindex
  - alle confs
  - alle states
  - alle indexes
  - nieuwe functie namen
    - function! linny#l2_index_filepath(term) +function! linny#l1_index_filepath(tax)
    - function! linny#l3_index_filepath(term, value) +function! linny#l2_index_filepath(tax, term)
    - function! linny#l2_config_filepath(term) +function! linny#l1_config_filepath(tax)
    - function! linny#l3_config_filepath(term, value) +function! linny#l2_config_filepath(tax, term)
    - function! linny#l2_state_filepath(term) +function! linny#l1_state_filepath(tax)
    - function! linny#l3_state_filepath(term, value) +function! linny#l2_state_filepath(tax, term)
    - function! linny#index_term_config(term) +function! linny#index_tax_config(tax)
    - function! linny#termValueLeafConfig(term, value) +function! linny#termConfig(tax, term)
    - function! linny#termLeafConfig(term) +function! linny#taxConfig(tax)
  - conf bestanden hernoemen
  - interne functionamen
  - fix testing

## Linny.vim 0.4.next (voor release)
- Bug:fix archived not working
- index moet ook array kunnen zijn (tags, contactpersonen)

## Linny.vim 0.4.6 - vr 27 sep 2019
- bug als rechts geen bestand is foutmelding
- bug bij verversen (R) ik mag niet schrijven in readonly buffer
- bug klikken op directory vraagt om extra klik
- Frontmatter autocomplete
- CRTL-A moet bij lege regel alle beschikbaar taxonomies tonen
- CTRL-L toont alle beschikbare terms in de huidige taxonomy
- remove H replace with R
- een paar syntax verbeteringen

## Linny.vim 0.4.5
- aanpassingen om met lindex te werken en te testen
- vader?
- hernoemen naar linny

- index-json files outside dropbox, configureer?
  - configureerbaar
  - impl. in wimpi-index
  - impl. in wimpi-vim
    - wimpi init functie
    - centrale yml-parse functie
    - centrale conf functie (enorme snelheidsverbetering)
    - indexdir functie
    - op alle plekken aanpassen
- wimpimenu: toon titels
  - voeg aan index toe in wimpi-index
  - pas calls aan in wimpi-vim

## Wimpi 0.2.5

- Harde refresh met async re-index

## Wimpi 0.2.4

- debugfunctie met t: waarden
- annuleren nieuw document
- star single document
- index moet ook float kunnen zijn
- refactor grep/move
- snel nieuwe map maken in taxo-kwalificatie
- niet automatisch een taxo-kwalificatie-config maken

## Wimpi 0.2.3
- wimpi: zoeken met async
- call index functie
- wimpimenu: onthoud per menu de key en value
- wimpimenu: refreshfunctie vanuit wimpi menu (CTRL-R)
- syntax: kopjes zien er gek uit
- fix typefout bij maken configuratie
- wimpi: naam bedenken voor Term+Value: [[Wimpi Taxonomies]]
- wimpimenu: maak nieuw document in huidige groep
  - vraag naam
  - set taxo_pair

## Wimpi 0.2.2
- sluit en open functie en commando's
- wimpimenu: sluit nerd als open
- wimpimenu: toggle functie ctrl f3
- wimpimenu: maak internal state tab-lokaal en niet script lokaal

## Wimpi 0.2.1
- verwijder echo bij openen 3rd level
- foutmelding slam project
- eindpuntconfiguratie: starred (boolean)
- group by is nu hoofdlettergevoelig
- veberg index van voorpagina

## Wimpi 0.2.0
- index-eindpunt-configuratie (integreer met WimpiMenu)
- wimpimenu: groepeer op
- voeg frontmatter configuratie aan indexbestanden toe

## Wimpi 0.1.0 - 27 juni 2019

- gebruik versienummer voor Wimpi-vim en Wimpi Totaal
- uitschakelen archetype_frontmatter syncer, niet meer nodig
- wimpimenu: open index-configuratie vanuit hoofdpagina
- net als archiveren, snelkoppeling voor move to trash
- wimpimenu: controleer breedte na klikken op enter
- verwijder action types trash, archive
- FrontMatter: verberg via folding Front Matter tekst.
- FrontMatter: nested yaml folding

## Wimpi 0.0.5
  - fix frontmatter syntax highligting laatste key, onderste frontmatter key niet vet
  - fix frontmatter syntax highligting underscores
  - snel nieuwe bestanden maken
  - toon match bij bestand bestaat niet
  - nmap t -> open link in new tab
  - vim-markdown-kiwi hernoemen naar Wimpi
  - woord afmaken repareren Enter
  - hernoemen naar wimpi-vim of wimpi
  - herschrijf configuratie, verplaats naar dropbox
  - verwijder overige indexen in index alfabetisch
  - frontmatter folding
  - index alfabet in quickmenu
  - frontmatter sync nog nodig?
  - Wimpi Vim Plugin: ctrl-enter FM keyword

## Wimpi 0.0.4 - apr 2019

- shortcut open in finder
- rename file and link
- highlight link
- delete and return to previous (,k)
- navigatie door frontmatter en titel index
- toon kleur als bestand niet bestaat (stackoverflow)

## Wimpi 0.0.3 - 2 apr 2019

- maak state voor writing mode met md files
- open externe files en bestanden

## Wimpi 0.0.2 - 1 april 2019

- shortcut verwijder document (,k)
- Actieregels implementeren
  - regel configuratie concept
  - Kopieer naar publicatie directory
  - aparte shortcut voor het uitvoeren van actieregels
  - archiveren
    - verplaats naar archief dir
- refactor helpers code
  - tpl directory
  - includes
- has_many_belong_to_many & has_many
- genereren bestanden met helpers
  - hoofd index
  - sub indexen op basis van configuratie
- configuratie bestand met templates in .vim
- keys lowercase
- naam bedenken: Wimpi

## Markdown-wiki-fork 0.0.1
- diverse functies bovenop markdown-wiki
