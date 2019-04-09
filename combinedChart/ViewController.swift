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
    
}

class ViewController: UIViewController,ChartViewDelegate {
    var testNa = [jsonstruct]()
    var country = [Double]()
    var population = [Double]()
    var name = [String]()
    @IBOutlet weak var region: UITextField!
    @IBOutlet var chartView: CombinedChartView!
    @IBAction func fetchDataBtn(_ sender: SSBouncyButton) {
        self.getdata()
    }
    
    
    @IBAction func OKNA(_ sender: Any) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        region.placeholder = "Filter By Region"
//        while self.name.count <= 0 {
//            getdata()
//        }
//        self.setChart(xValues: name, yValuesLineChart:  country, yValuesBarChart: population)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func getdata(){
        self.population = []
        self.country = []
        self.name = []
        var jsonUrlString: String?
        if (region.hasText) {
            jsonUrlString = "https://restcountries.eu/rest/v2/region/\(region.text ?? "europe")"
        } else {
            jsonUrlString = "https://restcountries.eu/rest/v2/name/eesti"
        }
        print("jsonUrlString => \(jsonUrlString ?? "europe")")
        guard let url = URL(string: jsonUrlString!) else {return}
        URLSession.shared.dataTask(with: url) { (data, responds,err) in
            guard let data = data else {return}
            do {
                
                self.testNa = try JSONDecoder().decode([jsonstruct].self, from: data)
                for mainarr in self.testNa{
                    print("mainarr.name => \(mainarr.name)")
                    self.population.append(Double(mainarr.population)/10000000)
                    self.country.append(Double(mainarr.population)/100000000)
                    self.name.append(mainarr.name)
                }
                self.setChart(xValues: self.name, yValuesLineChart:  self.country, yValuesBarChart: self.population)
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

