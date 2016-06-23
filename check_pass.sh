#!/usr/bin/expect
set hostlist [open ./host_list]
set ipaddrs [read $hostlist]
set pass [lindex $argv 0]
set timeout 60

log_file results.log ;#

foreach line [split $ipaddrs \n] {
    spawn ssh -oStrictHostKeyChecking=no -oCheckHostIP=no root@$line
    expect {
    	"denied" {
    		send_user "\n\nServer $line doesn't have that Password\n\n"
    		send \x03
    	}
    	"assword:" {
    		send "$pass\r"
    		exp_continue
    	}
    	"root@$line" {
    		send_user "\n\nServer $line password OK\n\n"
    		send "exit\r"
    	}
    	"resolve" {
    		send_user "\n\nServer $line not found\n\n"
    	}

    	"timed out" {
    		send_user "\n\nServer $line connection timed out\n\n"
    	}
    }
}
