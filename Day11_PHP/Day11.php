<?php
abstract class State
{
    const Running = 0;
    const Halted = 1;
}

class Interpreter
{
    public $program, $inputs, $outputs, $pc, $relativeBase, $state;
    public function __construct($program, $inputs)
    {
        $this->program = $program;
        $this->inputs = $inputs;
        $this->outputs = [];
        $this->pc = 0;
        $this->relativeBase = 0;
        $this->state = State::Running;
    }

    private function &get_or_init($key)
    {
        if (is_null($this->program[$key])) {
            $this->program[$key] = 0;
        }
        $x = &$this->program[$key];
        return $x;
    }

    public function &get_value($arg_no)
    {
        $addr_mode = $this->get_or_init($this->pc) / pow(10, $arg_no + 1) % 10;
        $index = $this->pc + $arg_no;
        switch ($addr_mode) {
            case 0:
                $ref = &$this->get_or_init($this->get_or_init($index));
                break;
            case 1:
                $ref = &$this->get_or_init($index);
                break;
            case 2:
                $ref = &$this->get_or_init($this->relativeBase + $this->get_or_init($index));
                break;
        }
        return $ref;
    }

    public function compute()
    {
        while (true) {
            $opcode = $this->program[$this->pc];
            switch ($opcode % 100) {
                case 1:
                    $ref = &$this->get_value(3);
                    $ref = $this->get_value(1) + $this->get_value(2);
                    $this->pc += 4;
                    break;
                case 2:
                    $ref = &$this->get_value(3);
                    $ref = $this->get_value(1) * $this->get_value(2);
                    $this->pc += 4;
                    break;
                case 3:
                    $tmp = array_shift($this->inputs);
                    if (is_null($tmp)) {
                        return;
                    }
                    $ref = &$this->get_value(1);
                    $ref = $tmp;
                    $this->pc += 2;
                    break;
                case 4:
                    array_push($this->outputs, $this->get_value(1));
                    $this->pc += 2;
                    break;
                case 5:
                    if ($this->get_value(1) != 0) {
                        $this->pc = $this->get_value(2);
                    } else {
                        $this->pc += 3;
                    }
                    break;
                case 6:
                    if ($this->get_value(1) == 0) {
                        $this->pc = $this->get_value(2);
                    } else {
                        $this->pc += 3;
                    }
                    break;
                case 7:
                    $ref = &$this->get_value(3);
                    if ($this->get_value(1) < $this->get_value(2)) {
                        $ref = 1;
                    } else {
                        $ref = 0;
                    }
                    $this->pc += 4;
                    break;
                case 8:
                    $ref = &$this->get_value(3);
                    if ($this->get_value(1) == $this->get_value(2)) {
                        $ref = 1;
                    } else {
                        $ref = 0;
                    }
                    $this->pc += 4;
                    break;
                case 9:
                    $this->relativeBase += $this->get_value(1);
                    $this->pc += 2;
                    break;
                case 99:
                    $this->state = State::Halted;
                    return;
            }
        }
    }
}

class Direction
{
    const Up = 0;
    const Right = 1;
    const Down = 2;
    const Left = 3;

    public static function turn(&$direction, $turn)
    {
        if ($turn == 0) {
            $turn = -1;
        }
        $direction = ($direction + $turn) % 4;
        if ($direction < 0) {
            $direction += 4;
        }
    }
}

class Painter
{
    public $interpreter, $x, $y, $grid, $direction;

    private function get_grid($x, $y)
    {
        if (is_null($this->grid[$x])) {
            $this->grid[$x] = [];
        }
        return $this->grid[$x][$y] ?? 0;
    }
    private function set_grid($x, $y, $value)
    {
        if (is_null($this->grid[$x])) {
            $this->grid[$x] = [$y => $value];
        } else {
            $this->grid[$x][$y] = $value;
        }
    }

    public function __construct($program, $starting_colour = 0)
    {
        $this->x = 0;
        $this->y = 0;
        $this->grid = [];
        $this->direction = Direction::Up;
        $this->interpreter = new Interpreter($program, []);
        $this->set_grid($this->x, $this->y, $starting_colour);
    }

    public function run()
    {
        while (true) {
            array_push($this->interpreter->inputs, $this->get_grid($this->x, $this->y));
            $this->interpreter->compute();
            if ($this->interpreter->state == State::Halted) {
                break;
            }

            $colour = array_shift($this->interpreter->outputs);
            $this->set_grid($this->x, $this->y, $colour);
            $turn = array_shift($this->interpreter->outputs);
            Direction::turn($this->direction, $turn);
            switch ($this->direction) {
                case Direction::Up:
                    $this->y += 1;
                    break;
                case Direction::Right:
                    $this->x += 1;
                    break;
                case Direction::Down:
                    $this->y -= 1;
                    break;
                case Direction::Left:
                    $this->x -= 1;
            }
        }
    }

    public function get_drawing() {
        $xs = array_keys($this->grid);
        $minx = min($xs);
        $maxx = max($xs);

        $miny = null;
        $maxy = null;
        foreach($this->grid as $column) {
            $local_ys = array_keys($column);
            $local_miny = min($local_ys);
            $local_maxy = max($local_ys);

            if(is_null($miny) || $local_miny < $miny) {
                $miny = $local_miny;
            }

            if(is_null($maxy) || $local_maxy > $maxy) {
                $maxy = $local_maxy;
            }
        }

        $result = '';
        for($y = $maxy; $y >= $miny; $y--){
            for($x = $minx; $x <= $maxx; $x++) {
                $result .= $this->get_grid($x, $y) == 0 ? '.' : '#';
            }
            $result .= "\n";
        }
        return $result;
    }
}

$file_content = file_get_contents("input.txt");
$program = array_map(function ($s) {
    return (int) $s;
}, explode(',', $file_content));

$painter = new Painter($program);
$painter->run();
$tiles_painted = 0;
foreach ($painter->grid as $column) {
    $tiles_painted += count($column);
}
echo $tiles_painted . "\n";

$painter = new Painter($program, 1);
$painter->run();
echo $painter->get_drawing();
