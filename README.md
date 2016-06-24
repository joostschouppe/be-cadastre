# stats4belgium
A place to share scripts useful for analyzing raw government data

For now: only some scripts to turn the current Kadaster dumps as provided to every municipality in Belgium into some nice statistics about ownership, number of residences et cetera.

Before you start: you will need:
- the geometry of parcels (you can use either the dataset provided by the Kadaster, or the cleaned version provided by AGIV, if you're in Flanders)
- the data about parcels. This is provided to municipalities as txt files.
- a dataset with a division of your territory of interest. We assume this to be statistical sectors. If you don't have them yet, there's a national open dataset available.
- a way to convert either DAA (a field in one of the txt's) or your territory devisions into postal codes. You will need those to complete the address of parcels.

The scripts (starting with 00_ etc) assume you have already followed the instructions you will find on the wiki here: 
https://github.com/joostschouppe/stats4belgium/wiki/Kadaster

Scripts are written in SPSS. You can get a free one month trial version. The programming is quite simple, so it shouldn't be too difficult to translate the scripts into the language of your choice.
