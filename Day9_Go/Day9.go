package main

import (
	"fmt"
	"io/ioutil"
	"strings"
	"strconv"
)

type State int

const (
    Running State = iota
    Halted
)

type Interpreter struct {
	program map[int64]*int64
	inputs, outputs []int64
	pc, relativeBase int64
	state State
}

func NewInterpreter(program, inputs []int64) Interpreter {
	var program_map = map[int64]*int64{}
	for i, x := range program {
		var p = new(int64)
		*p = x
		program_map[int64(i)] = p
	}
	return Interpreter {
		program: program_map,
		inputs: append(inputs[:0:0], inputs...),
		outputs: []int64{},
		pc: 0,
		relativeBase: 0,
		state: Running,
	}
}

func Pow10(n int) int {
	var r = 1
	for i := 0; i < n; i++ {
		r *= 10
	}
	return r
}

func get_or_init(prog *map[int64]*int64, key int64) *int64 {
	var x, ok = (*prog)[key]
	if ok {
		return x
	}
	var p = new(int64)
	*p = 0
	(*prog)[key] = p
	return p
}

func (self *Interpreter) get_value(arg_no int) *int64 {
	var addr_mode = *get_or_init(&self.program, self.pc) / int64(Pow10(arg_no + 1)) % 10
	var index = self.pc + int64(arg_no)
	switch addr_mode {
	case 0:
		return get_or_init(&self.program, *get_or_init(&self.program, index))
	case 1:
		return get_or_init(&self.program, index)
	case 2:
		return get_or_init(&self.program, self.relativeBase + *get_or_init(&self.program, index))
	}
	panic("Invalid addressing mode")
}

func (self *Interpreter) compute() {
	loop: for {
		opcode := *self.program[self.pc]

		switch int(opcode) % 100 {
		case 1:
			*self.get_value(3) = *self.get_value(1) + *self.get_value(2)
			self.pc += 4
		case 2:
			*self.get_value(3) = *self.get_value(1) * *self.get_value(2)
			self.pc += 4
		case 3:
			if len(self.inputs) == 0 {
				break loop
			}
			*self.get_value(1), self.inputs = self.inputs[0], self.inputs[1:]
			self.pc += 2
		case 4:
			self.outputs = append(self.outputs, *self.get_value(1))
			self.pc += 2
		case 5:
			if *self.get_value(1) != 0 {
				self.pc = *self.get_value(2)
			} else {
				self.pc += 3
			}
		case 6:
			if *self.get_value(1) == 0 {
				self.pc = *self.get_value(2)
			} else {
				self.pc += 3
			}
		case 7:
			if *self.get_value(1) < *self.get_value(2) {
				*self.get_value(3) = 1
			} else {
				*self.get_value(3) = 0
			}
			self.pc += 4
		case 8:
			if *self.get_value(1) == *self.get_value(2) {
				*self.get_value(3) = 1
			} else {
				*self.get_value(3) = 0
			}
			self.pc += 4
		case 9:
			self.relativeBase += *self.get_value(1)
			self.pc += 2
		case 99:
			self.state = Halted
			break loop
		}
	}
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}

func main() {
	var file_content, err = ioutil.ReadFile("input.txt")
	check(err)
	var program []int64
	for _, x := range strings.Split(strings.TrimSpace(string(file_content)), ",") {
		var i, err = strconv.ParseInt(x, 10, 64)
		check(err)
		program = append(program, i)
	}

	var interpreter  = NewInterpreter(program, []int64{2})
	interpreter.compute()
	fmt.Println(interpreter.outputs)
}