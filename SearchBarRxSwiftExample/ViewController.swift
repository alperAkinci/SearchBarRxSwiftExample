//
//  ViewController.swift
//  SearchBarRxSwiftExample
//
//  Created by Alper Akinci on 07/11/2017.
//  Copyright © 2017 Alper Akinci. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var shownPizzas = [String]()
    let allPizzas = ["Margharita",
                     "Hawaiian",
                     "Mexicana",
                     "Tropicana",
                     "Pepperoni",
                     "Chicken Supreme",
                     "Pepperoni Special",
                     "Chicken Sweetcorn",
                     "Chicken Mushroom"]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    /**
     Dispose bag:
      When you subscribe to observables, often times you want to unsubscribe from it when object is being deallocated.
     In Rx we have something called DisposeBag which is normally used to keep all things that you want to unsubscribe from in the deinit process.
     For some cases it is not needed, but the general rule of thumb is to always create that bag and add disposables to it.
    */
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self

        /**
         SearchBar:
         We will now observe the text in UISearchBar.
         It is really easy, because RxCocoa (which is extension of RxSwift) has this built in for us!
         UISearchBar and many more controls given by Cocoa frameworks has support from Rx team.
         In our case, with usage of UISearchBar, we can use it’s property rx.text, which emits signals once the text in the search bar change.
        */
        searchBar
            .rx.text // Observable property thanks to RxCocoa
            .orEmpty // Make it non-optional
            /**
             subscribe(onNext:): subscribing to the observable property, which produces signals.
             It’s like you’re telling your phone “Alrighty, now every time you got something new, show it to me”. And it will show you everything new.
             In our case we need only new values, but subscribe has more wrappers with events like onError, onCompleted etc.
             */
            .debounce(0.5, scheduler: MainScheduler.instance) // // Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
            /**
             filter:
             What if user typed something, refreshed the table view, and then deleted his phrase making new value that is empty?
             Yeah, we will send query with empty parameter…
             In our case we don’t want to do it so we have to somehow protect us against it.
             How? With the usage of filter().
             Why do I have to use filter on one value? filter() works on collections!!!”.
             But don’t think about Observable as a value/object. It’s a stream of values, that will happen eventually.
             And therefore you will easily understand the usage of functional blocks. To filter our values we will do it as you would do it with an array of strings. Simply:
            */
            .filter{ !$0.isEmpty } // Filter for non-empty query.
            .subscribe(onNext: { [unowned self] query in // Here we will be notified of every new value
                self.shownPizzas = self.allPizzas.filter { $0.hasPrefix(query) } // We now do our "API Request" to find cities.
                self.tableView.reloadData() // And reload table view data.
            })
            .addDisposableTo(disposeBag)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shownPizzas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "developerCell")!
        cell.textLabel?.text = shownPizzas[indexPath.row]
        return cell
    }

}

