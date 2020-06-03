function status = describe(theItem, howMuch)

% describe -- Explanation of an item.
%  describe('theFunction') shows help for 'theFunction'.
%  describe(theObject) describes theObject itself, but not
%   its inherited parts.
%  describe(theObject, 'full') describes theObject fully.
%  describe(theNonObject, ...) describes theNonObject.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, describe('describe'), return, end
if nargin < 2, howMuch = ''; end

theName = inputname(1);

if isstr(theItem)
   help(theItem)
  elseif isobject(theItem)
   disp(' ')
   if ~isempty(theName)
      disp([' ## Name: ' theName])
   end
   if isobject(theItem)
      disp([' ## Public Class: ' class(theItem)])
      s = super(theItem);
      while isobject(s)
         disp([' ## Public SuperClass: ' class(s)])
         s = super(s);
      end
      disp([' ## Protected Methods:'])
      theMethods = methods(class(theItem));
      for i = 1:length(theMethods)
         if strcmp(class(theItem), theMethods{i})
            disp(['    ' class(theItem) '/' theMethods{i} '() // Constructor'])
           else
            disp(['    ' class(theItem) '/' theMethods{i} '()'])
         end
      end
      disp([' ## Private Fields:']), disp(struct(theItem))
      if strcmp(lower(howMuch), 'full')
         if isobject(super(theItem))
            disp([' ## Inherited by ' class(theItem) ':'])
            describe(super(theItem), 'full')
            theItem = super(theItem);
         end
      end
   end
  else
   disp([' ## Name: ' theName])
   disp([' ## Class: ' class(theItem)])
   disp([' ## Value:'])
   disp(theItem)
end
