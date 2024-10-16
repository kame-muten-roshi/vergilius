<?php
class util {

    /** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
    *                          PUBLIC METHOD SECTION                         *
    * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

    /**
    * alltrim($expression) : string
    */

    /**
    * Removes all leading and trailing spaces or parsing characters from the
    * specified character expression.
    *
    * @param string $expression
    * Specifies an expression of string type to remove leading and trailing
    * spaces.
    *
    * @param string
    * alltrim() returns the specified expression without leading or trailing
    * spaces.
    */
    public static function alltrim($expression) {
        $expression = trim($expression);

        do {
            $expression = str_replace('  ', ' ', $expression);
        } while (strpos($expression, '  ') > 0);

        return $expression;
    }

}
?>
