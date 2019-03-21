every 1.minute do
  command "curl -I http://0.0.0.0:4567/api/v1/scheduled_health_check"
end