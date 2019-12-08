use std::fs;
use permutohedron::Heap;

#[derive(PartialEq)]
pub enum State {
    Running,
    Halted
}

struct Interpreter {
    program: Vec<i32>,
    inputs: Vec<i32>,
    outputs: Vec<i32>,
    pc: i32,
    state: State
}

impl Interpreter {
    pub fn new(program: &Vec<i32>, inputs: &Vec<i32>) -> Interpreter {
        Interpreter {
            program: program.clone(),
            inputs: inputs.clone(),
            outputs: Vec::new(),
            pc: 0,
            state: State::Running
        }
    }

    fn get_value(&self, index: i32, addr_mode: i32) -> i32 {
        let value = self.program[index as usize];
        return match addr_mode {
            0 => self.program[value as usize],
            1 => value,
            _ => panic!("Invalid addressing mode")
        };
    }

    pub fn compute(&mut self) {
        loop {
            let opcode = self.program[self.pc as usize];

            match opcode % 100 {
            1 => {
                let return_addr = self.get_value(self.pc + 3, 1);
                self.program[return_addr as usize] = self.get_value(self.pc + 1, opcode / 100 % 10) + self.get_value(self.pc + 2, opcode / 1000 % 10);
                self.pc += 4;
            },
            2 => {
                let return_addr = self.get_value(self.pc + 3, 1);
                self.program[return_addr as usize] = self.get_value(self.pc + 1, opcode / 100 % 10) * self.get_value(self.pc + 2, opcode / 1000 % 10);
                self.pc += 4
            },
            3 => {
                let return_addr = self.get_value(self.pc + 1, 1);
                if self.inputs.is_empty() {
                    break;
                }
                self.program[return_addr as usize] = self.inputs.remove(0);
                self.pc += 2
            },
            4 => {
                self.outputs.push(self.get_value(self.pc + 1, opcode / 100 % 10));
                self.pc += 2
            },
            5 => {
                self.pc = if self.get_value(self.pc + 1, opcode / 100 % 10) != 0 {
                    self.get_value(self.pc + 2, opcode / 1000 % 10)
                } else {
                    self.pc + 3
                }
            },  
            6 => {
                self.pc = if self.get_value(self.pc + 1, opcode / 100 % 10) == 0 {
                    self.get_value(self.pc + 2, opcode / 1000 % 10)
                } else {
                    self.pc + 3
                }
            },
            7 => {
                let return_addr = self.get_value(self.pc + 3, 1);
                self.program[return_addr as usize] = if self.get_value(self.pc + 1, opcode / 100 % 10) < self.get_value(self.pc + 2, opcode / 1000 % 10) {
                    1
                } else {
                    0
                };
                self.pc += 4
            },
            8 => {
                let return_addr = self.get_value(self.pc + 3, 1);
                self.program[return_addr as usize] = if self.get_value(self.pc + 1, opcode / 100 % 10) == self.get_value(self.pc + 2, opcode / 1000 % 10) {
                    1} else {0};
                self.pc += 4
            },
            99 => {
                self.state = State::Halted;
                break
            },
            _ => panic!("Invalid opcode")
            }
        }
    }
}

fn main() {
    let program: Vec<i32> = fs::read_to_string("input.txt").unwrap().split(",").map(|x| x.parse::<i32>().unwrap()).collect();

    let mut max = None;
    let mut inputs = vec![0, 1, 2, 3, 4];
    let heap = Heap::new(&mut inputs);
    for permutation in heap {
        let mut signal = 0;
        for input in permutation {
            let mut interpereter = Interpreter::new(&program, &vec![input, signal]);
            interpereter.compute();
            signal = interpereter.outputs[0];
        }
        
        max = match max {
            None => Some(signal),
            Some(x) => if signal > x { Some(signal) } else { max }
        }
    }
    println!("{}", max.unwrap());

    let mut max = None;
    let mut inputs = vec![9, 7, 8, 5, 6];
    let heap = Heap::new(&mut inputs);
    for permutation in heap {
        let mut interpreters: Vec<Interpreter> = permutation.into_iter().map(|input| Interpreter::new(&program, &vec![input])).collect();
        let mut signal = 0;
        while interpreters.last().unwrap().state != State::Halted {
            for interpreter in &mut interpreters {
                interpreter.inputs.push(signal);
                interpreter.compute();
                signal = interpreter.outputs.remove(0);
            }
        }
        max = match max {
            None => Some(signal),
            Some(x) => if signal > x { Some(signal) } else { max }
        }
    }
    println!("{}", max.unwrap());

}