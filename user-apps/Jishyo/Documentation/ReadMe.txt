Jishyo
------

Jishyo is an English -> Japanese dictionary. Currently it only supports English 
queries. In the future I hope to add support for kana and kanji queries, as 
well as multi-radical lookups for kanji. Jishyo is based in large part on code 
from Jim Breen's xjdic. It also uses the dictionary data from the same software.


Features
--------

* 'exact', 'similar', and 'related' queries, that return successively greater 
  number of results.
* localized for Thai and Japanese


Dependencies
------------

* a recent version of gnustep-core (http://www.gnustep.org/)
* a Japanese font.

With current versions of GNUstep, your default system font will need to support 
Japanese characters. Alternatively, you could try Alexander Malmberg's font 
substitution patch at: 

http://web.telia.com/~u42308495/alex/font_substitution_1.1.patch

A short explanation for using the patch can be found at:

http://mediawiki.gnustep.org/index.php/I18n#Current_Status_2


Install
-------

make install (as root)


Contributing
------------

Patches, complaints, feedback, and suggestions are welcome. Please send to 
rburns@softhome.net. I'm especially partial to localizations. Localizations for 
Jishyo can be done entirely from the Localizable.strings file.

