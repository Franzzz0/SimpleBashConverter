#!/usr/bin/bash
red='^[a-z]+_to_[a-z]+$'
rec='^-?[0-9]+(\.[0-9]+)?$'
ren='^[0-9]+$'
definitions="definitions.txt"
touch "$definitions"
convert() {
	if [ -s "$definitions" ]; then
		mapfile lines < "$definitions"
		line_number=${#lines[@]}
		echo "Type the line number to convert units or '0' to return"
		for (( i=0; i<line_number; i++ )); do
			echo "$((i + 1)). ${lines[i]}"
		done
		while true; do
			read -r input
			ren='^[0-9]+$'
			if [[ "$input" =~ $ren ]] && [ "$input" -ge 0 ] && [ "$input" -le "$line_number" ]; then
				if [ "$input" -gt 0 ]; then
					read -r -a line <<< "$(sed "${input}!d" "$definitions")"
					ratio="${line[1]}"
					echo "Enter a value to convert:"
					while true; do
						read -r value
						if [[ "$value" =~ $rec ]]; then
							break
						fi
						echo "Enter a float or integer value!"
					done
					result=$(echo "scale=2; $ratio * $value" | bc -l)
					printf "Result: %s\n" "$result"
				fi
				break
			else
				echo "Enter a valid line number!"
			fi
		done
	else
		echo "Please add a definition first!"
	fi
}
add() {
	while true; do
		echo "Enter a definition:"
		read -r -a user_input
		arr_length="${#user_input[@]}"
		definition="${user_input[0]}"
		constant="${user_input[1]}"
		red='^[a-z]+_to_[a-z]+$'
		rec='^-?[0-9]+(\.[0-9]+)?$'
		if [ "$arr_length" -eq 2 ] && [[ "$definition" =~ $red ]] && [[ "$constant" =~ $rec ]]; then
			echo "${user_input[*]}" >> "$definitions"
			break			
		fi
		echo "The definition is incorrect!"
	done
}
delete() {	
	if [ -s "$definitions" ]; then
		echo "Type the line number to delete or '0' to return"
		mapfile lines < "$definitions"
		line_number=${#lines[@]}
		for (( i=0; i<line_number; i++ )); do
			echo "$((i + 1)). ${lines[i]}"
		done
		while true; do
			read -r input
			ren='^[0-9]+$'
			if [[ "$input" =~ $ren ]] && [ "$input" -ge 0 ] && [ "$input" -le "$line_number" ]; then
				if [ "$input" -gt 0 ]; then
					sed -i "${input}d" "$definitions"
				fi
				break
			else
				echo "Enter a valid line number!"
			fi
		done
			
	else
		echo "Please add a definition first!"
	fi
}
echo "Welcome to the Simple converter!"
while true; do
	echo "Select an option
0. Type '0' or 'quit' to end program
1. Convert units
2. Add a definition
3. Delete a definition"
	read -r input
	case "$input" in
		0|"quit")
			echo "Goodbye!"
			break
			;;
		1)
			convert;;
		2)
			add;;
		3)
			delete;;
		*)
			echo "Invalid option!";;
	esac
done

echo "Enter a definition:"
read -a user_input
arr_length="${#user_input[@]}"
definition="${user_input[0]}"
constant="${user_input[1]}"
red='^[a-z]+_to_[a-z]+$'
rec='^-?[0-9]+(\.[0-9]+)?$'
if [ "$arr_length" -eq 2 ] && [[ "$definition" =~ $red ]] && [[ "$constant" =~ $rec ]]; then
	echo "Enter a value to convert:"
	while : ; do
		read value
		if [[ "$value" =~ $rec ]]; then
			break
		fi
		echo "Enter a float or integer value!"
	done
	result=$(echo "scale=2; $constant * $value" | bc -l)
	printf "Result: %s\n" "$result"
else
	echo "The definition is incorrect!"
fi