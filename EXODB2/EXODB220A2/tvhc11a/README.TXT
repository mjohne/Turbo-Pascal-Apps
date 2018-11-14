                           TVHC Improvements
                              Version 1.1a
                             December 1993

                         Far Niente Productions



    Introduction  Ü
  ßßßßßßßßßßßßßßßßß
    This package is intended to make your TVHC work much more pleasant.
    It makes it easy to edit your help texts in the IDE and get nice
    pin-pointing error reports in the message window for easy error
    tracking.

    THERE ARE NO WARRANTIES WHATSOEVER, USE THIS PACKAGE ON YOUR OWN
    RISK.

    This is intended for Borland Pascal, but if you port it to BC++ I'd
    like a copy.

    I hope that you will find this package useful.



    Package Contents  Ü
  ßßßßßßßßßßßßßßßßßßßßß
    This package contains a TVHC message filter and an improved TVHC
    which is better at reporting the actual line number that caused an
    error or warning.

    TVHC2MSG.PAS  Borland IDE message filter
    TVHC.PAS      Improved TVHC, better error reports
    README.TXT    This file



    Instructions  Ü
  ßßßßßßßßßßßßßßßßß
    Compile TVHC2MSG and the modified TVHC included in this package, put
    the resulting EXEs somewhere in your path, add a TVHC tool under
    Options³Tools if you haven't already done so and add this to the
    tool's command line:

      $SAVE ALL $CAP MSG(TVHC2MSG) $NOSWAP

    (Tip: You can copy the text and paste it into the input line)
    You also have to add the name of your help file to the above, the
    TVToys TVHC Tool command line looks like this:

      $SAVE ALL $CAP MSG(TVHC2MSG) $NOSWAP helptest helptest helpctx

    I always use $SAVE ALL which saves all editor files, but you might
    prefer $SAVE CUR which only saves the current editor.

    You can use TVHC2MSG with the original TVHC, but you won't get very
    good error line references. You also have to define ForceExtension,
    see TVHC2MSG.PAS



    TVHC Bugs Fixed  Ü
  ßßßßßßßßßßßßßßßßßßßß
    Reports the .TXT file name in error messages rather than the .HLP
    file.

    If there is an error opening or creating a file, the file name in
    question is now printed correctly.



    TVHC Improvements  Ü
  ßßßßßßßßßßßßßßßßßßßßßß
    Reports the actual line numbers of all lines containing unresolved
    help references. Originally TVHC attributed any such errors to the
    last line of the file.

    Reports both actual line numbers for redefined help topics rather
    than the last line of the second help topic.

    (The "actual" line refers to the line where the offending item
    actually resides)



    Tip  Ü
  ßßßßßßßß
    You might want to review your Options³Environment³Preferences
    options:

      [X] Close on go to source

    Pressing Ctrl+Enter in the message window closes the message window


      [X] Auto track source

    Moving the highlight bar in the message window highlights the
    corresponding source line immediately.



    Author  Ü
  ßßßßßßßßßßß
      Bug reports, enhancements, contributions and postcards are always
      welcome!

      My internet address:

        d91-pbr@nada.kth.se

      You can reach me from CompuServe by sending mail to:

        INTERNET:d91-pbr@nada.kth.se

      Mail:

        Peter Brandstr”m          (Peter Brandstrom)
        Roslagsgatan 10
        S-113 55 Stockholm
        Sweden, Europe



