module main

import term
import os

const logo = os.read_file('logo.txt') or { '' }

const color = 59064 // #00E6B8
const accent = 16744258 // #FF8C42

fn center_line(line string) string {
	width, _ := term.get_terminal_size()
	mut padding := (width - line.len) / 2
	if padding < 0 {
		padding = 0
	}
	return ' '.repeat(padding) + line
}

fn center_text(text string) string {
	mut result := []string{}
	for line in text.split('\n') {
		result << center_line(line)
	}
	return result.join('\n')
}

fn center_block(block string) string {
	lines := block.split('\n')
	mut ordered_lines := lines.clone()
	ordered_lines.sort_by_len()
	max_len := ordered_lines.last().len

	mut centered_lines := []string{}
	for line in lines {
		centered_lines << center_line(line + ' '.repeat(max_len - line.len))
	}

	return centered_lines.join('\n')
}
