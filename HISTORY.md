v0.0.3 - Aug 06, 2011
---------------------

### Fixed:
  * Move the version number to it's own Ruby file to make sure gem building produces no trouble. (#2)

v0.0.2 - Jun 03, 2011
---------------------

Added contributions from Colin Gemmell 
([pythonandchips.net](http://pythonandchips.net), 
 [@pythonandchips](http://github.com/pythonandchips)).

### Fixed:
  * **Compatibility with 1.8.7 and JRuby**
  * **Fix authentication problem**
  * Fixed published time being invalid
  * Fix feeds like Imgur which fails at getting Entry#feed
  * Fix tests on a Mac

### Added:
  * Implement GReader#html_processors.
  * Implement read/starred checks by for entries using Entry#read? and 
  Entry#starred?.
  * A `ParseError` will now be thrown in the weird chance that Google Reader 
  JSON that the gem can't handle.

### Changed:
  * Refine the image fetching algo.

v0.0.1 - March 21, 2011
-----------------------

First release.
