//
//  ViewController.swift
//  combinedChart
//
//  Created by Admin on 9/4/2562 BE.
//  Copyright © 2562 th.ac.kmutnb.www. All rights reserved.
//
import Charts
import SSBouncyButton
import UIKit
import Alamofire
struct jsonstruct:Decodable {
    let name:String
    let capital:String
    let alpha2Code:String
    let alpha3Code:String
    let region:String
    let subregion:String
    let population: Int
    let gini: Double?
    
}

class ViewController: UIViewController,ChartViewDelegate {
    var testNa = [jsonstruct]()
    var country = [Double]()
    var population = [Double]()
    var gini = [Double]()
    var name = [String]()
    var alpha3Code = [String]()
    @IBOutlet weak var region: UITextField!
    @IBOutlet var chartView: CombinedChartView!
    @IBAction func fetchDataBtn(_ sender: SSBouncyButton) {
        self.getdata()
    }
    
    
    @IBAction func OKNA(_ sender: Any) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        region.placeholder = "Enter Country"
    }
    func getdata(){
        var jsonUrlString: String?
        if (region.hasText) {
            if (region.text == "all") {
                jsonUrlString = "https://restcountries.eu/rest/v2/all"
            } else {
                jsonUrlString = "https://restcountries.eu/rest/v2/name/\(region.text ?? "thailand")?fullText=true"
            }
        } else {
            jsonUrlString = "https://restcountries.eu/rest/v2/name/thailand"
        }
        print("jsonUrlString => \(jsonUrlString ?? "europe")")
        guard let url = URL(string: jsonUrlString!) else {return}
        URLSession.shared.dataTask(with: url) { (data, responds,err) in
            guard let data = data else {return}
            do {
                
                self.testNa = try JSONDecoder().decode([jsonstruct].self, from: data)
                for mainarr in self.testNa{
                    print("mainarr.name => \(mainarr.name)")
                    self.population.append(Double(mainarr.population)/1000000)
                    self.gini.append(mainarr.gini ?? 0.00)
                    self.alpha3Code.append(mainarr.alpha3Code)
                }
                print("self.name => \(self.alpha3Code)")
                print("self.population => \(self.population)")
                print("self.gini => \(self.gini)")
                self.setChart(xValues: self.alpha3Code, yValuesLineChart:  self.gini, yValuesBarChart: self.population)
                super.viewDidLoad()
            } catch let jsonErr {
                print("Error serializing json", jsonErr)
            }
            }.resume()
    }
    func setChart(xValues: [String], yValuesLineChart: [Double], yValuesBarChart: [Double]) {
        chartView.noDataText = "Please provide data for the chart."
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        var yVals2 : [BarChartDataEntry] = [BarChartDataEntry]()
        for i in 0..<xValues.count {
            yVals1.append(ChartDataEntry(x: Double(i), y: yValuesLineChart[i],data: xValues as AnyObject?))
            yVals2.append(BarChartDataEntry(x: Double(i), y: yValuesBarChart[i],data: xValues as AnyObject?))
        }
        
        let lineChartSet = LineChartDataSet(values: yVals1, label: "Line Data")
        lineChartSet.colors = [NSUIColor.green]
        let barChartSet: BarChartDataSet = BarChartDataSet(values: yVals2, label: "Bar Data")
        let data: CombinedChartData = CombinedChartData()
        data.barData=BarChartData(dataSets: [barChartSet])
        if yValuesLineChart.contains(0) == false {
            data.lineData = LineChartData(dataSets:[lineChartSet] )
            
        }
        chartView.data = data
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:xValues)
        chartView.xAxis.granularity = 1
    }
}
