//
//  ViewController.swift
//  SouthernDraw
//
//  Created by Patrick Beninga on 11/10/18.
//  Copyright © 2018 Patrick Beninga. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    @IBOutlet var imgView: UIImageView!
    var pgr:UIPanGestureRecognizer!
    var startPoint:CGPoint!
    var points = [CGPoint]()
    var lastPoint:CGPoint!
    var loginView:UIView!
    var roomCodefield:UITextField!
    var nameField:UITextField!
    var manager:SocketManager!
    var socket:SocketIOClient!
    var prompt:UILabel!
    var colorSelector:UIView!
    var color = UIColor.black
    
    override func viewDidLoad() {
        
        manager =  SocketManager(socketURL: URL(string: "https://southern-draw-dev.herokuapp.com/")! ,config: [.log(true),.forceWebsockets(true)])
        socket = manager.socket(forNamespace: "/game/player")
        super.viewDidLoad()
        pgr = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(pan:)))
        imgView.image = UIImage(named: "iphoneX.png")
        
        socket.on("join_room_status") {data, ack in
            print("here")
        }
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on("start_game_ios"){data, ack in
            let prompt = (data[0] as! [String:String])["prompt"]
            self.prompt.text = "Draw " + prompt!
            self.prompt.font = UIFont(name: "Caviar Dreams", size: 14.0)
            self.prompt.sizeToFit()
            self.prompt.center.x = self.view.center.x
            self.view.addSubview(self.prompt)
            UIView.animate(withDuration: 0.3, animations: {
                self.prompt.center.y = self.view.frame.height - 160
            })
            print(prompt!)
        }

        self.imgView.frame = self.view.frame
        self.imgView.addGestureRecognizer(pgr)
        startPoint = CGPoint(x:0.0, y:0.0)
        lastPoint = startPoint
        self.imgView.isUserInteractionEnabled = false
        print(UIFont.familyNames)
        let logoView = UIImageView.init(image: UIImage(named: "logo.png"))
        logoView.frame = CGRect(x: 0, y: -50, width: 300, height: 300/1.38)
        let roomCodeLabel = UILabel(frame: CGRect(x:0, y:200, width:200, height: 20))
        roomCodeLabel.text = "Enter your room code"
        roomCodeLabel.textAlignment = .center
        roomCodefield = UITextField(frame: CGRect(x:0, y:225, width:200, height:40))
        let nameFieldLabel = UILabel(frame: CGRect(x:0, y:280, width:200, height: 20))
        roomCodefield.textAlignment = .center
        roomCodefield.placeholder = "A0B1C2"
        nameFieldLabel.text = "Player Name"
        nameField = UITextField(frame: CGRect(x:0, y:305, width:200, height:40))
        nameField.textAlignment = .center
        nameField.placeholder = "Player 1"
        roomCodefield.layer.shadowOffset = CGSize(width: 6, height: 6)
        roomCodefield.layer.shadowRadius = 6
        roomCodefield.layer.shadowOpacity = 0.37
        roomCodefield.layer.cornerRadius = 7
        nameField.layer.shadowRadius = 6
        nameField.layer.shadowOffset = CGSize(width: 6, height: 6)
        nameField.layer.shadowOpacity = 0.37
        nameField.layer.cornerRadius = 7
        nameFieldLabel.textAlignment = .center
        roomCodefield.delegate = self
        roomCodefield.font = UIFont(name: "Caviar Dreams", size: 20.0)
        nameField.font = UIFont(name: "Caviar Dreams", size: 20.0)
        nameFieldLabel.font = UIFont(name: "Caviar Dreams", size: 14.0)
        roomCodeLabel.font = UIFont(name: "Caviar Dreams", size: 14.0)
        nameField.delegate = self
        roomCodefield.backgroundColor = UIColor.white
        nameField.backgroundColor = UIColor.white
        loginView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/1.5))
        loginView.center = self.view.center
        roomCodefield.center.x = loginView.center.x
        nameField.center.x = loginView.center.x
        logoView.center.x = loginView.center.x
        roomCodeLabel.center.x = loginView.center.x
        nameFieldLabel.center.x = loginView.center.x
        loginView.addSubview(logoView)
        loginView.addSubview(roomCodefield)
        loginView.addSubview(nameField)
        loginView.addSubview(roomCodeLabel)
        loginView.addSubview(nameFieldLabel)
        loginView.backgroundColor = UIColor.clear
        self.view.insertSubview(loginView, aboveSubview: imgView)
        self.prompt = UILabel(frame: CGRect(x:0, y:self.view.frame.height+100, width:100, height:100))
        self.prompt.center.x = self.view.center.x
        self.prompt.center.y = 40
        let loginButton = UIButton(type: .custom)
        loginButton.setImage(UIImage(named: "button.png"), for: .normal)
        loginButton.frame = CGRect(x:0, y: 450, width: 150, height:55)
        loginButton.center.x = loginView.center.x
        loginView.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(self.login(button:)), for: .touchUpInside)
        let rightHand1 = UIImageView(image: UIImage(named: "righthand.png"))
        let rightHand2 = UIImageView(image: UIImage(named: "righthand.png"))
        let leftHand1 = UIImageView(image: UIImage(named: "lefthand.png"))
        let leftHand2 = UIImageView(image: UIImage(named: "lefthand.png"))
        rightHand1.frame = CGRect(x:0, y:0, width:40, height:20)
        rightHand2.frame = CGRect(x:0, y:0, width:40, height:20)
        leftHand1.frame = CGRect(x:0, y:0, width:40, height:20)
        leftHand2.frame = CGRect(x:0, y:0, width:40, height:20)
        leftHand1.center.y = nameField.center.y
        leftHand1.center.x = nameField.frame.origin.x - 40
        leftHand2.center.y = roomCodefield.center.y
        leftHand2.center.x = roomCodefield.frame.origin.x - 40
        rightHand1.center.y = nameField.center.y
        rightHand1.center.x = nameField.frame.origin.x + nameField.frame.width + 40
        rightHand2.center.y = roomCodefield.center.y
        rightHand2.center.x = roomCodefield.frame.origin.x + roomCodefield.frame.width + 40
        colorSelector = UIView(frame: CGRect(x:10, y:self.view.frame.height, width: self.view.frame.width-10, height: 100))
        
        let blackColorSelect = UIButton(type: .custom)
        blackColorSelect.frame = CGRect(x:15, y:20, width: 60, height:60)
        blackColorSelect.backgroundColor = UIColor.black
        blackColorSelect.layer.cornerRadius = 30
        blackColorSelect.layer.borderColor = UIColor.white.cgColor
        blackColorSelect.layer.borderWidth = 4
        blackColorSelect.addTarget(self, action: #selector(self.changeColor(button:)), for: .touchUpInside)
        let blueColorSelect = UIButton(type: .custom)
        blueColorSelect.frame = CGRect(x:self.view.frame.width/4+5, y:20, width: 60, height:60)
        blueColorSelect.backgroundColor = UIColor(red: 255/255, green: 118/255, blue: 151/255, alpha: 1.0)
        blueColorSelect.layer.cornerRadius = 30
        blueColorSelect.layer.borderColor = UIColor.white.cgColor
        blueColorSelect.layer.borderWidth = 4
        blueColorSelect.addTarget(self, action: #selector(self.changeColor(button:)), for: .touchUpInside)
        let greenColorSelect = UIButton(type: .custom)
        greenColorSelect.frame = CGRect(x:2*self.view.frame.width/4, y:20, width: 60, height:60)
        greenColorSelect.backgroundColor = UIColor(red: 87/255, green: 172/255, blue: 176/255, alpha: 1.0)
        greenColorSelect.layer.cornerRadius = 30
        greenColorSelect.layer.borderColor = UIColor.white.cgColor
        greenColorSelect.layer.borderWidth = 4
        greenColorSelect.addTarget(self, action: #selector(self.changeColor(button:)), for: .touchUpInside)
        let redColorSelect = UIButton(type: .custom)
        redColorSelect.frame = CGRect(x:3*self.view.frame.width/4 - 5, y:20, width: 60, height:60)
        redColorSelect.backgroundColor =  UIColor(red: 173/255, green: 203/255, blue: 133/255, alpha: 1.0)
        redColorSelect.layer.cornerRadius = 30
        redColorSelect.layer.borderColor = UIColor.white.cgColor
        redColorSelect.layer.borderWidth = 4
        redColorSelect.addTarget(self, action: #selector(self.changeColor(button:)), for: .touchUpInside)
        self.colorSelector.addSubview(blueColorSelect)
        self.colorSelector.addSubview(blackColorSelect)
        self.colorSelector.addSubview(greenColorSelect)
        self.colorSelector.addSubview(redColorSelect)
        self.view.insertSubview(colorSelector!, aboveSubview: self.imgView)
        self.loginView.addSubview(leftHand1)
        self.loginView.addSubview(leftHand2)
        self.loginView.addSubview(rightHand1)
        self.loginView.addSubview(rightHand2)
        socket.connect()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    @objc func changeColor(button:UIButton){
        self.color = button.backgroundColor!
        let orignalSize = button.frame.size
        UIView.animate(withDuration: 0.1, animations: {
            button.frame.size = CGSize(width: 80, height: 80)
            button.frame.origin.x -= 10
            button.frame.origin.y -= 10
            button.layer.cornerRadius = 40
        }) { (Bool) in
            UIView.animate(withDuration: 0.1, animations: {
                button.frame.size = orignalSize
                button.frame.origin.x += 10
                button.frame.origin.y += 10
                button.layer.cornerRadius = 30
            })
        }
    }
    @objc func login(button:UIButton){
        startGame()
        socket.emit("test", ["hi"])
        self.imgView.image = UIImage(named: "iphoneX.png")
        self.nameField.resignFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.loginView.frame.origin.y = 0
        }) { (Bool) in
            UIView.animate(withDuration: 0.75, animations: {
                self.loginView.frame.origin.y = self.view.frame.height + 100
            }, completion: { (Bool) in
                UIView.animate(withDuration: 0.2, animations: {
                    self.colorSelector.frame.origin.y  = self.view.frame.height-260
                }, completion: { (Bool) in
                    UIView.animate(withDuration: 0.2, animations: {
                         self.colorSelector.frame.origin.y  = self.view.frame.height-160
                    })
                })
            })
        }
    }
    func startGame(){
        self.imgView.isUserInteractionEnabled = true
        var start_game_dict = [String: Any]()
        var dim = [String: Int]()
        dim["width"] = Int(self.imgView.frame.width)
        dim["height"] =  Int(self.imgView.frame.height)
        start_game_dict["pkt_name"] = "join_room"
        start_game_dict["room_number"] = self.roomCodefield.text
        start_game_dict["user_name"] = self.nameField.text
        start_game_dict["screen_dim"] = dim
        let jsonData = try! JSONSerialization.data(withJSONObject: start_game_dict, options: [])
        let decoded = String(data: jsonData, encoding: .utf8)!
        print(decoded)
        socket.emit("join_room", decoded)
        
    }
    @objc func handlePan(pan:UIPanGestureRecognizer){
        let currentPoint = pan.location(in: self.view)
        if (pan.state == .began){
            startPoint = currentPoint
            lastPoint = currentPoint
            points.append(startPoint)

        }else if(pan.state == .changed){
            points.append(currentPoint)
            UIGraphicsBeginImageContext(self.view.frame.size)
            self.imgView.image!.draw(in: self.view.frame)
            let context = UIGraphicsGetCurrentContext()!
            context.setLineWidth(5.0);
            context.setStrokeColor(color.cgColor)
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x:currentPoint.x, y:currentPoint.y))
            context.strokePath()
            lastPoint = currentPoint
            self.imgView.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
        }
        else if(pan.state == .ended){
            var data = [String: Any]()
            var data_points = [[String : Int]]()
            data["pkt_name"] = "draw_data_ios_move"
            data["color"] = self.getColor()
            for point in points{
                data_points.append(["x":Int(point.x), "y":Int(point.y)])
            }
            data["points"] = data_points
            let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
            let decoded = String(data: jsonData, encoding: .utf8)!
            socket.emit("draw_data_ios_move", decoded)
            points = [CGPoint]()
            socket.emit("draw_data_ios_end_line")
        }
        if(points.count >= 4){
            var data = [String: Any]()
            var data_points = [[String : Int]]()
            data["pkt_name"] = "draw_data_ios_move"
            data["color"] = self.getColor()
            for point in points{
                data_points.append(["x":Int(point.x), "y":Int(point.y)])
            }
            data["points"] = data_points
            let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
            let decoded = String(data: jsonData, encoding: .utf8)!
            socket.emit("draw_data_ios_move", decoded)
            points = [CGPoint]()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func getColor() -> String{
        if color.isEqual(UIColor(red: 255/255, green: 118/255, blue: 151/255, alpha: 1.0)){
            return  "#ff7697"
        }
        if color.isEqual(UIColor(red: 87/255, green: 172/255, blue: 176/255, alpha: 1.0)){
            return  "#57acb0"
        }
        if color.isEqual(UIColor(red: 173/255, green: 203/255, blue: 133/255, alpha: 1.0)){
            return  "#b2cb85"
        }
        return "#0"
        
    }
/*var jsonData: NSData = NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.PrettyPrinted, error: &error)!
 if error == nil {
 return NSString(data: jsonData, encoding: NSUTF8StringEncoding)! as String
 }
*/

}

