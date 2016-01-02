//
//  OverviewViewController.swift
//  ThereYet
//
//  Created by Andrew Whitehead on 1/1/16.
//  Copyright © 2016 Mobi. All rights reserved.
//

import UIKit
import CoreData

import Charts

class OverviewViewController: CenterViewController, ChartViewDelegate {

    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var pieChart: PieChartView!
    
    let fakeData = [""]
    
    var courses = [Course]()
    var checkIns = [CheckIn]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCourses()
        loadCheckIns()
        
        setupBarChart()
        
        setupPieChart()
    }
    
    func loadCheckIns() {
        let fetchRequest = NSFetchRequest(entityName: "CheckIn")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try checkIns = context.executeFetchRequest(fetchRequest) as! [CheckIn]
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadCourses() {
        let fetchRequest = NSFetchRequest(entityName: "Course")
        fetchRequest.predicate = NSPredicate(format: "hexColor != nil")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        do {
            try courses = context.executeFetchRequest(fetchRequest) as! [Course]
        } catch let error as NSError {
            print(error)
        }
    }
    
    func setupBarChart() {
        barChart.delegate = self
        
        barChart.descriptionText = "";

        barChart.drawBarShadowEnabled = false
        barChart.drawValueAboveBarEnabled = true
        
        barChart.maxVisibleValueCount = 60
        barChart.pinchZoomEnabled = false
        barChart.drawGridBackgroundEnabled = false
        
        let xAxis = barChart.xAxis
        xAxis.labelPosition = .Bottom
        xAxis.labelFont = UIFont.systemFontOfSize(10)
        xAxis.drawGridLinesEnabled = false
        xAxis.spaceBetweenLabels = 2
        
        let leftAxis = barChart.leftAxis
        leftAxis.labelFont = UIFont.systemFontOfSize(10)
        leftAxis.labelCount = 8
        leftAxis.valueFormatter = NSNumberFormatter()
        leftAxis.valueFormatter?.maximumFractionDigits = 1
        leftAxis.labelPosition = .OutsideChart
        leftAxis.spaceTop = 0.15
        
        let rightAxis = barChart.rightAxis
        rightAxis.drawGridLinesEnabled = false
        rightAxis.labelFont = UIFont.systemFontOfSize(10)
        rightAxis.labelCount = 8
        rightAxis.valueFormatter = leftAxis.valueFormatter
        rightAxis.spaceTop = 0.15
        
        barChart.legend.position = .BelowChartLeft;
        barChart.legend.form = .Square
        barChart.legend.formSize = 9.0
        barChart.legend.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        barChart.legend.xEntrySpace = 4.0
        
        //----------------------------
        
        var xVals = [String]()
        for course in courses {
            xVals.append(course.title!)
        }
        
        var yVals = [BarChartDataEntry]()
        /*//RANDOM DATA
        for (var i = 0; i < courses.count; i++) {
            let val = Double(arc4random_uniform(UInt32(50 + 1)))
            yVals.append(BarChartDataEntry(value: val, xIndex: i))
        }*/
        
        for (var i = 0; i < courses.count; i++) {
            let course = courses[i]

            var tempCheckIns = [CheckIn]()
            tempCheckIns.appendContentsOf(checkIns)
            tempCheckIns = tempCheckIns.filter({$0.course == course})
            
            yVals.append(BarChartDataEntry(value: Double(tempCheckIns.count), xIndex: i))
        }
        
        let set1 = BarChartDataSet(yVals: yVals, label: "Check-Ins")
        set1.barSpace = 0.35
        
        var dataSets = [BarChartDataSet]()
        dataSets.append(set1)
        
        let data = BarChartData(xVals: xVals, dataSets: dataSets)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 10))
        
        barChart.data = data
    }
    
    func setupPieChart() {
        pieChart.delegate = self
        
        pieChart.usePercentValuesEnabled = true
        pieChart.holeTransparent = true
        pieChart.holeRadiusPercent = 0.58
        pieChart.transparentCircleRadiusPercent = 0.61
        pieChart.descriptionText = ""
        pieChart.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)

        pieChart.drawCenterTextEnabled = true
        
        pieChart.centerText = "Attendance by Day"
        
        pieChart.drawHoleEnabled = true
        pieChart.rotationAngle = 0.0
        pieChart.rotationEnabled = true
        pieChart.highlightPerTapEnabled = true
        
        let l = pieChart.legend
        l.position = .RightOfChart
        l.xEntrySpace = 7.0
        l.yEntrySpace = 0.0
        l.yOffset = 0.0
        
        //-----------------------
        
        let mult = 100
        
        var yVals1 = [BarChartDataEntry]()
        //IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
        for (var i = 0; i < 7; i++) {
            var checkInsThatAreOnBlankDay = [CheckIn]()
            checkInsThatAreOnBlankDay.appendContentsOf(checkIns)
            checkInsThatAreOnBlankDay = checkInsThatAreOnBlankDay.filter({NSCalendar.currentCalendar().components(.Weekday, fromDate: $0.timestamp!).weekday-1 == i})
            
            yVals1.append(BarChartDataEntry(value:Double(checkInsThatAreOnBlankDay.count)/Double(checkIns.count), xIndex: i))
        }
    
        let xVals = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let dataSet = PieChartDataSet(yVals: yVals1, label: "")
        dataSet.sliceSpace = 2.0
        
        //add a lot of colors
        var colors = [UIColor]()
        colors.appendContentsOf(ChartColorTemplates.vordiplom())
        colors.appendContentsOf(ChartColorTemplates.joyful())
        colors.appendContentsOf(ChartColorTemplates.colorful())
        colors.appendContentsOf(ChartColorTemplates.liberty())
        colors.appendContentsOf(ChartColorTemplates.pastel())
        colors.append(UIColor(red: 51/255.0, green: 181/255.0, blue: 229/255.0, alpha: 1))
        colors.append(UIColor(red: 85/255.0, green: 130/255.0, blue: 255/255.0, alpha: 1))
        
        dataSet.colors = colors
        
        let data = PieChartData(xVals: xVals, dataSet: dataSet)

        let pFormatter = NSNumberFormatter()
        pFormatter.numberStyle = .PercentStyle
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(pFormatter)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 11))
        data.setValueTextColor(UIColor.whiteColor())

        pieChart.data = data
        pieChart.highlightValues(nil)
        
        pieChart.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .EaseOutBack)
    }
    
}
