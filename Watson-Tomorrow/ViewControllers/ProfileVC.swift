//
//  ProfileVC.swift
//  Watson-Tomorrow
//
//  Created by Leon Mak on 8/10/17.
//  Copyright © 2017 Leon Mak. All rights reserved.
//

import UIKit
import Charts

class ProfileVC: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var barChartViewSavings: BarChartView!
    @IBOutlet weak var barChartViewSpendings: BarChartView!
    
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let unitsSold = [2000.0, 4000.0, 6000.0, 3000.0, 12000.0, 16000.0, 4000.0, 18000.0, 2000.0, 4000.0, 5000.0, 4000.0]

    override func viewDidLoad() {
        super.viewDidLoad()
        barChartViewSavings.delegate = self
        setChart(dataPoints: months, values: unitsSold)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartViewSavings.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Balance")
        
        
        let chartData = BarChartData(dataSets: [chartDataSet])
        barChartViewSavings.data = chartData
        barChartViewSavings.chartDescription?.text = "Balance in the bank"
        
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        barChartViewSavings.xAxis.labelPosition = .bottom
        barChartViewSavings.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .easeInBounce)
        
        let ll = ChartLimitLine(limit: 10.0, label: "Emergency Fund")
        barChartViewSavings.rightAxis.addLimitLine(ll)
        
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
        print("\(entry.y) in \(months[Int(entry.x)])")
    }
    
}
