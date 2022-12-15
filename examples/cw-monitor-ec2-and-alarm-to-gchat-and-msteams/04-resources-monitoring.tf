###################################
# CloudWatch dashboards resources #
###################################

resource "aws_cloudwatch_dashboard" "apps_resources_status_cwdashboard" {
  dashboard_name = "${var.sys_name}-apps-resources-status"
  dashboard_body = <<EOF
{
    "widgets":
    [
        {
            "height": 2,
            "width": 24,
            "y": 0,
            "x": 0,
            "type": "alarm",
            "properties":
            {
                "title": "${var.app_name}",
                "alarms":
                [
                    "${aws_cloudwatch_metric_alarm.app_i_cpu_alarm.arn}",
                    "${aws_cloudwatch_metric_alarm.app_i_mem_alarm.arn}",
                    "${aws_cloudwatch_metric_alarm.app_i_disk_alarm.arn}"
                ]
            }
        }
    ]
}
EOF

}

resource "aws_cloudwatch_dashboard" "apps_resources_details_cwdashboard" {
  dashboard_name = "${var.sys_name}-apps-resources-details"
  dashboard_body = <<EOF
{
    "widgets":
    [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 5,
            "properties":
            {
                "metrics":
                [
                    [
                        "AWS/EC2",
                        "CPUUtilization",
                        "InstanceId",
                        "${aws_instance.app_i.id}",
                        {
                            "label": "${var.sys_name}-${var.app_name}-i"
                        }
                    ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "yAxis":
                {
                    "left":
                    {
                        "min": 0,
                        "max": 100
                    }
                },
                "legend":
                {
                    "position": "right"
                },
                "annotations":
                {
                    "horizontal":
                    [
                        {
                            "label": "CPU Utilization (%) >",
                            "value": 75,
                            "fill": "above"
                        }
                    ]
                },
                "title": "CPU Utilization (%)"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 5,
            "width": 24,
            "height": 5,
            "properties":
            {
                "metrics":
                [
                    [
                        "CWAgent",
                        "mem_used_percent",
                        "InstanceId",
                        "${aws_instance.app_i.id}",
                        {
                            "label": "${var.sys_name}-${var.app_name}-i"
                        }
                    ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "Memory Usage (%)",
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "legend":
                {
                    "position": "right"
                },
                "yAxis":
                {
                    "left":
                    {
                        "min": 0,
                        "max": 100
                    }
                },
                "annotations":
                {
                    "horizontal":
                    [
                        {
                            "label": "Memory Usage (%) >",
                            "value": 75,
                            "fill": "above"
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 10,
            "width": 24,
            "height": 5,
            "properties":
            {
                "metrics":
                [
                    [
                        "CWAgent",
                        "disk_used_percent",
                        "InstanceId",
                        "${aws_instance.app_i.id}",
                        {
                            "label": "${var.sys_name}-${var.app_name}-i"
                        }
                    ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "title": "Disk Usage (%)",
                "region": "${var.aws_region}",
                "stat": "Average",
                "period": 300,
                "legend":
                {
                    "position": "right"
                },
                "yAxis":
                {
                    "left":
                    {
                        "min": 0,
                        "max": 100
                    }
                },
                "annotations":
                {
                    "horizontal":
                    [
                        {
                            "label": "Disk Usage (%) >",
                            "value": 75,
                            "fill": "above"
                        }
                    ]
                }
            }
        }
    ]
}
EOF

}
