<?php
abstract class base_dao {

    /** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
    *                          PUBLIC METHOD SECTION                         *
    * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
    public function add($model) {}
    public function delete($model) {}
    public function get($expression, $filter_condition = null) {}
    public function get_by_id($id) {}
    public function get_by_name($name) {}
    public function is_related($id) {}
    public function modify($model) {}

    /** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
    *                        PROTECTED METHOD SECTION                        *
    * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
    protected function load_data($model, $data) {}

}
?>
