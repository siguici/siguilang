module main

import term
import os
import regex

const logo = os.read_file('logo.txt') or { '' }

const color = 59064 // #00E6B8
const accent = 16744258 // #FF8C42

fn center_line(line string) string {
	width, _ := term.get_terminal_size()
	mut padding := (width - visible_width(line)) / 2
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
	return center_block_lines(block.split('\n'))
}

fn center_block_lines(lines []string) string {
	mut lens := lines.map(visible_width(it))
	lens.sort(|a, b| a < b)
	max_len := lens.last()

	mut centered_lines := []string{}
	for line in lines {
		centered_lines << center_line(line + ' '.repeat(max_len - visible_width(line)))
	}

	return centered_lines.join('\n')
}

fn strip_ansi(s string) string {
	// CSI (eg: \x1b[38;2;255;0;0m)
	mut re1 := regex.regex_opt(r'\x1b\[[0-9;:?]*[ -/]*[@-~]') or { panic(err) }
	mut cleaned := re1.replace(s, '')

	// OSC (eg: \x1b]0;Title\x07)
	mut re2 := regex.regex_opt(r'\x1b\][0-9;]*(?:.*)?\x07') or { panic(err) }
	cleaned = re2.replace(cleaned, '')

	return cleaned
}

fn visible_width(s string) int {
	text := strip_ansi(s)
	mut width := 0
	for _ in text.runes() {
		width += 1
	}
	return width
}
