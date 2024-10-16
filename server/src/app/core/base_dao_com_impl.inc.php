<?php
include_once 'base_dao.inc.php';
include_once 'util.inc.php';

abstract class base_dao_com_impl extends base_dao {

    protected $com;
    protected $connection;
    protected $model_class;

    /** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
    *                          PUBLIC METHOD SECTION                         *
    * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

    /**
    * get($expression, $filter_condition = null) : array -> @Override
    * get_by_id($id) : object|null -> @Override
    * id_exists($id) : boolean
    */

    /**
    * Performs a search by id and name.
    *
    * @param string $expression
    * Specifies the expression to search for.
    *
    * @param string $filter_condition (optional)
    * Specifies the record filtering condition.
    *
    * @return array
    * array with data if successful and empty array otherwise.
    */
    # @Override
    public function get($expression, $filter_condition = null) {
        $records = [];

        try {
            $this->connect();

            if (isset($this->connection)) {
                $expression = iconv('UTF-8', 'ISO-8859-1', $expression);
                $result = $this->connection->get($expression);

                if ($xml = simplexml_load_string($result)) {
                    foreach ($xml as $row) {
                        $record = $this->load_data(new $this->model_class,
                            $row);

                        if (!is_null($record))
                            $records[] = $record;
                    }
                } else {
                    # print 'Could not load XML string.' . '<br>';
                }
            }
        } catch (Exception $ex) {
            print 'ERROR: ' . $ex->getMessage() . '<br>';
        }

        $this->disconnect();

        return $records;
    }

    /**
    * Performs a search by id.
    *
    * @param integer $id
    * Specifies the id to search for.
    *
    * @return object|null
    * object if successful and null otherwise.
    */
    # @Override
    public function get_by_id($id) {
        # begin { parameter validations }
        if (!util::param_id_valid($id)) {
            return null;
        }
        # end { parameter validations }

        $record = null;

        try {
            $this->connect();

            if (isset($this->connection)) {
                $result = $this->connection->get_by_id($id);

                if ($xml = simplexml_load_string($result)) {
                    foreach ($xml as $row) {
                        $record = $this->load_data(new $this->model_class,
                            $row);
                        break;
                    }
                } else {
                    # print 'Could not load XML string.' . '<br>';
                }
            }
        } catch (Exception $ex) {
            print 'ERROR: ' . $ex->getMessage() . '<br>';
        }

        $this->disconnect();

        return $record;
    }

    /**
    * Checks if an id exists.
    *
    * @param integer $codigo
    * Specifies the id to verify.
    *
    * @return boolean
    * true if it exists or an error occurs and false otherwise.
    */
    public function id_exists($id) {
        # begin { parameter validations }
        if (!util::param_id_valid($id)) {
            return true;
        }
        # end { parameter validations }

        $exists = true;

        try {
            $this->connect();

            if (isset($this->connection)) {
                $exists = $this->connection->id_exists($id);
            }
        } catch (Exception $ex) {
            print 'ERROR: ' . $ex->getMessage() . '<br>';
        }

        $this->disconnect();

        return $exists;
    }

    /** ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ *
    *                        PROTECTED METHOD SECTION                        *
    * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

    /**
    * connect() : null
    * data_valid($data) : boolean
    * disconnect() : null
    * id_valid($value) : boolean
    * load_data($model, $data) : object|null -> @Override
    * model_valid($model) : boolean
    */

    /**
    * Connects to COM (Component Object Model).
    */
    protected function connect() {
        if (isset($this->com) && !empty($this->com)) {
            try {
                $this->connection = new COM($this->com, NULL, CP_ACP);
            } catch (Exception $ex) {
                print 'ERROR: ' . $ex->getMessage() . '<br>';
                die();
            }
        }
    }

    /**
    * Checks if the $data variable is of the SimpleXMLElement object type.
    *
    * @param object $data
    * Specifies the variable to check.
    *
    * @return boolean
    * true if valid and false otherwise.
    */
    protected function data_valid($data) {
        if (isset($data) &&
                gettype($data) === 'object' &&
                get_class($data) === 'SimpleXMLElement') {
            return true;
        }

        return false;
    }

    /**
    * Disconnects from COM (Component Object Model).
    */
    protected function disconnect() {
        if (isset($this->connection)) {
            $this->disconnect = null;
        }
    }

    /**
    * Determines if a variable is of type integer and falls within a given
    * range.
    *
    * @param integer $value
    * Specifies the variable to evaluate.
    *
    * @return boolean
    * true if valid and false otherwise.
    */
    protected function id_valid($value) {
        return util::integer_range($value, 1, 99999);
    }

    /**
    * Loads data from an object of type SimpleXMLElement to another object
    * of the type specified in the $model parameter.
    *
    * @param object $model
    * Specifies the model into which the data is loaded.
    *
    * @param SimpleXMLElement object $data.
    * Specifies the object that contains the data.
    *
    * @return object|null
    * object if successful and null otherwise.
    */
    # @Override
    protected function load_data($model, $data) {
        if (!$this->model_valid($model) || !$this->data_valid($data))
            return null;

        try {
            $id = (int) $data->id;
            $name = (string) $data->name;
            $active = (boolean) ($data->active == 'true') ? true : false;

            $model->set_id($id);
            $model->set_name($name);
            $model->set_active($active);

            return $model;
        } catch (Exception $ex) {
            print 'ERROR: ' . $ex->getMessage() . '<br>';
            die();
        }
    }

    /**
    * Checks if the $model variable is of the object type of the $model_class
    * property.
    *
    * @param object $model
    * Specifies the variable to check.
    *
    * @return boolean
    * true if valid and false otherwise.
    */
    protected function model_valid($model) {
        if (isset($this->model_class) && !empty($this->model_class)) {
            if (isset($model) &&
                    gettype($model) === 'object' &&
                    get_class($model) === $this->model_class) {
                return true;
            }
        }

        return false;
    }

}
?>
