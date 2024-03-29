SLEEP_TIME=30
full_flag=0
low_flag_30=0
low_flag_20=0
crit_flag=0
vcrit_flag=0
while [ true ]; do
	capc=$(cat /sys/class/power_supply/BAT0/capacity)
	if [[ $(cat /sys/class/power_supply/BAT0/status) != "Discharging" ]]; then # -- charging state
		shutdown -c                                                               # -- closing the pending shutdowns from critical shutdown action
		low_flag=0
		crit_flag=0
		vcrit_flag=0
		if (($capc >= 90)); then
			if ((full_flag != 1)); then
				notify-send "    Battery FULL" "Unplug the charger"
				full_flag=1
			fi
		fi
		SLEEP_TIME=30

	else # -- discharging state
		full_flag=0
		if (($capc >= 60)); then
			SLEEP_TIME=40
		else
			SLEEP_TIME=30
			if (($capc > 20)) && (($capc <= 30)); then
				SLEEP_TIME=20
				if ((low_flag_30 != 1)); then
					notify-send "    Battery LOW" "\nBattery at 30%" -u low -t 5000
					low_flag_30=1
				fi
			fi
			if (($capc > 10)) && (($capc <= 20)); then
				SLEEP_TIME=20
				if ((low_flag_20 != 1)); then
					notify-send "    Battery LOW" "\nBattery at 20%, search the charger" -u normal
					low_flag_20=1
				fi

			fi
			if (($capc <= 10)); then
				SLEEP_TIME=15
				if ((crit_flag != 1)); then
					notify-send "    CRITICAL level reached" "Plug-in the charger" -u critical
					crit_flag=1
				fi
			fi
			if (($capc <= 5)); then
				SLEEP_TIME=10
				if ((vcrit_flag != 1)); then
					notify-send "    BYE BYE" "SHUTDOWN in 1 minute..\n" -u critical
					shutdown
					vcrit_flag=1
				fi

			fi
		fi

	fi
	#echo "$capc sl_time = $SLEEP_TIME"
	sleep $SLEEP_TIME
done
