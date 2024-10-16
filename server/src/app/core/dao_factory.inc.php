<?php
abstract class dao_factory {

    protected static $dao_class_impl;

    /**
    * Creates an instance of the DAO class.
    *
    * @return object|null
    * object if successful and null otherwise.
    */
    public static function create_dao() {
        if (isset(static::$dao_class_impl) && !empty(static::$dao_class_impl)) {
            try {
                $dao = new static::$dao_class_impl;
                return $dao;
            } catch (Exception $ex) {
                print 'ERROR: ' . $ex->getMessage() . '<br>';
            }
        }

        return null;
    }

}
?>
