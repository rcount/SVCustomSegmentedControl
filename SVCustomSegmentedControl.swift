//
//  SVCustomSegmentedControl.swift
//  ColorTest
//
//  Created by Stephen Vickers on 7/21/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//
//  This was wrote Following Mark Moeykens from Big Mountain Studios
//  I added the ability to have either a full rectangle behind each button, or a line underneath
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

@IBDesignable
class SVCustomSegmentedControl: UIControl {
    
    //MARK: - Private variables used in the class -
    
    ///Enum to get the shape of the highlight for the current 
    ///selected button
    private enum ShapeType: Int{
        case rectangle
        case line
    }

    ///Private array to hold an array of button for the control
    private var buttons = [UIButton]()
    
    ///Private UIView for the selector background for the control
    private var selector: UIView!
    
    ///Private variable for the shape of the selector
    private var shape: ShapeType = .rectangle
    
    //MARK: - Public Variables for the class -
    
    ///Public variable to hold the current Index of the Selected Segment of the Controll
    public var selectedSegmentIndex = 0
    
    //MARK: - @IBInspectable variables for the class
    
    ///@IBInspectable variable to set the borderWidth from the Storyboard builder
    ///
    ///When it's set it just sets the layer.borderWidth to the new borderWidth
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    ///@IBInspectable to set the layer.cornerRadius of the control
    ///
    ///When it's set self.updateView() is called, where most of the work is done to create the view
    @IBInspectable var cornerRadius: CGFloat = 0.0{
        didSet{
            self.updateView()
        }
    }

    ///@IBInspectable to set if the view is a rounded view, which is completely rounded on the ends
    ///
    ///When this is set we set the corner radius to either half of the height or the @IBInspectable
    /// of cornerRadius
    @IBInspectable var roundedView: Bool = false{
        didSet{
            let rounded = self.layer.frame.height / 2
            self.cornerRadius = self.roundedView == true ? rounded : self.cornerRadius
        }
    }
    
    ///@IBInspectable to set the borderColor
    ///
    /// -Default: UIColor.clear
    ///When it is set then we just set the layer.borderColor
    @IBInspectable var borderColor: UIColor = .clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    ///@IBInspectable to get the buttonTitles
    ///
    ///A Coma Seperated value is expected 
    /// - example "Red, Green, Blue"
    ///
    /// When it's set then we call self.updateView() where most of the work is done
    @IBInspectable var buttonTitles: String = "" {
        didSet{
            self.updateView()
        }
    }
    
    ///@IBInspectable to get the color of the Text for the button labels
    ///
    /// - Default: UIColor.lightText
    ///
    /// When it's set then we call self.updateView() where most of the work is done
    @IBInspectable var textColor: UIColor = .lightText{
        didSet{
            self.updateView()
        }
    }
    
    ///@IBInspectable to get the selector shape for the the selector
    ///
    /// -Set: set the shape of the selector, Default is .rectangle
    ///
    /// -Returns: self.shape.rawValue
    @IBInspectable var selectorShape: Int{
        get{
            return self.shape.rawValue
        }
        set{
            self.shape = ShapeType(rawValue: newValue) ?? .rectangle
            self.updateView()
        }
    }
    
    ///@IBInspectable to get the color of the selector background
    ///
    //// -Default: UIColor.darkGray
    ///
    /// When it's set then we call self.updateView() where most of the work is done
    @IBInspectable var selectorColor: UIColor = .darkGray{
        didSet{
            self.updateView()
        }
    }
    
    ///@IBInspectable to get the color of the selected Index text color
    ///
    /// -Default: UIColor.white
    ///
    /// When it's set then we call self.updateView() where most of the work is done
    @IBInspectable var selectorTextColor: UIColor = .white{
        didSet{
            self.updateView()
        }
    }
    
    ///Function to setup and update the look of the control
    private func updateView(){
        
        //set cliptoBounds true, that way the selector view will never be outside of the border
        self.clipsToBounds = true
        
        //remove all the buttons
        self.buttons.removeAll()
        
        //remove all the subviews of the control
        self.subviews.forEach({ $0.removeFromSuperview()})
        
        //set the layer.CornerRadius of the view
        self.layer.cornerRadius = self.cornerRadius
        
        //get the titles of the buttons that you want to use
        let titles = self.buttonTitles.components(separatedBy: ",")
        
        //create buttons for the number of titles we have
        for title in titles{
            
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.setTitleColor(self.textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
            self.buttons.append(button)
        }
        
        //get the selectorWidth
        let selectorWidth = self.frame.width / self.buttons.count.cgFloat
        
        //switch on the shape to see if it should be a rectangle behind the button or a line underneath it
        switch self.shape {
            
        //create the rectangle if it should be one
        case .rectangle:
            self.selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: self.frame.height))
            self.selector.layer.cornerRadius = self.cornerRadius
            self.selector.backgroundColor = self.selectorColor
            self.addSubview(self.selector)
        
        //create the line if it should be a line
        case .line:
            self.selector = UIView(frame: CGRect(x: 0, y: self.layer.frame.height - 10, width: selectorWidth, height: 10))
            self.selector.backgroundColor = self.selectorColor
            self.insertSubview(self.selector, at: 1)
            
        }
        
        //set the first button in the array to be chosen
        self.buttons[0].setTitleColor(self.selectorTextColor, for: .normal)
        
        //create a horizontal stack view for the buttons
        //set the alignment ot fill and the distribution to fillEqually
        let stackView = UIStackView(arrangedSubviews: self.buttons)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        //Add the stack view to the subviews
        self.addSubview(stackView)
        
        //set the constraits for the stackview to hold it with in the bounds of the control
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    ///Function for when a button is clicked inside of the segmented controller
    @objc public func buttonClicked(button clickedButton: UIButton){
        
        //loop through the buttons and get the button and buttonIndex
        for (buttonIndex, button) in self.buttons.enumerated(){
            
            //set the button title color to the normal text color for all the buttons as we go through them
            button.setTitleColor(self.textColor, for: .normal)
            
            //if the current button is the button we clicked then we go on and change things
            if button == clickedButton{
                
                //set the selector start posistion to the width of the control divided 
                //by the number of buttons in the array, this is actually setting the width of the selector, but we use it as 
                //the start posistion for the selector behind the buttons
                let selectorStartPosistion = self.frame.width / self.buttons.count.cgFloat
                
                //move the selector to the button we have clicked
                //if the button clicked is at index 0 then selectorStartPosistion * buttonIndex will 
                //be 0, If we have three button in the array and buttonIndex is 1 
                //then the selectorStartPosistion * buttonIndex will be 33, putting the selector behind the midle button
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame.origin.x = selectorStartPosistion * buttonIndex.cgFloat
                })
                
                //change the title color for the selected button
                button.setTitleColor(self.selectorTextColor, for: .normal)
                
                //set the selectedSegmentIndex to the buttonIndex, 
                //this is so the CustomSegmentedControl can be use like the standard segmented control
                self.selectedSegmentIndex = buttonIndex
                
                //send the action for value Changed, that way in a ViewController we can switch on the current slectedSegmentIndex
                self.sendActions(for: .valueChanged)
            }
        }
    }
    
   

}

//MARK: - Helper extensions for the class -

///Fileprivate extenstion on Int
fileprivate extension Int {
    
    ///calculated variable to turn an Int into a CGFloat.
    var cgFloat: CGFloat{
        return CGFloat(self)
    }
}


