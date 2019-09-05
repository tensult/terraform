output "spot_id" {
  value       = "${aws_spot_fleet_request.spot-fleet-request.id}"
  description = "Spot fleet request id"
}
