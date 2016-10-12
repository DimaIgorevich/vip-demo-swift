//
//  ArtistViewController.swift
//  VIPDemo
//
//  Created by Daniela Dias on 07/10/2016.
//  Copyright © 2016 ustwo. All rights reserved.
//

import UIKit


// MARK: - ArtistViewControllerInput

protocol ArtistViewControllerInput: ArtistPresenterOutput {

}


// MARK: - ArtistViewControllerOutput

protocol ArtistViewControllerOutput {

    var albums: [Album]? { get }

    func fetchAlbums(artistId: String)
}


// MARK: - ArtistViewController

class ArtistViewController: UIViewController, ErrorPresenter {

    var output: ArtistViewControllerOutput!
    var router: ArtistRouter!

    let artistView = ArtistView()

    fileprivate var albumsViewModels: [AlbumViewModel] = []

    var artist: Artist?


    // MARK: - Initializers

    init(artist: Artist, configurator: ArtistConfigurator = ArtistConfigurator.sharedInstance) {

        self.artist = artist

        super.init(nibName: nil, bundle: nil)

        configure(configurator: configurator)
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)

        configure(configurator: ArtistConfigurator.sharedInstance)
    }


    // MARK: - Configurator

    private func configure(configurator: ArtistConfigurator = ArtistConfigurator.sharedInstance) {

        configurator.configure(viewController: self)
    }


    // MARK: - View lifecycle

    override func loadView() {

        view = artistView
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        setupTitle()
        setupTableView()
        fetchAlbums()
    }


    // MARK: - Setup

    private func setupTitle() {

        if let artistName = artist?.name {

            title = artistName

        } else {

            title = Strings.Artist.screenTitle
        }
    }

    private func setupTableView() {

        artistView.tableView.delegate = self
        artistView.tableView.dataSource = self
        artistView.tableView.register(AlbumTableViewCell.self, forCellReuseIdentifier: AlbumTableViewCell.reuseIdentifier())
        artistView.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    }


    // MARK: - Event handling

    func fetchAlbums() {

        if let artistId = artist?.mbid {

            output.fetchAlbums(artistId: artistId)
        }
    }

    func refresh() {

        fetchAlbums()
    }
}


// MARK: - UITableViewDataSource

extension ArtistViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return albumsViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AlbumTableViewCell.reuseIdentifier(), for: indexPath) as? AlbumTableViewCell else {

            return UITableViewCell()
        }

        let viewModel = albumsViewModels[indexPath.row]
        cell.viewModel = viewModel

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        return Strings.Artist.albumsTitle
    }
}


// MARK: - UITableViewDelegate

extension ArtistViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Do nothing for now
    }
}


// MARK: - ArtistPresenterOutput

extension ArtistViewController: ArtistViewControllerInput {

    func displayAlbums(viewModels: [AlbumViewModel]) {

        albumsViewModels = viewModels
        artistView.tableView.reloadData()
        artistView.refreshControl.endRefreshing()
    }

    func displayError(viewModel: ErrorViewModel) {

        artistView.refreshControl.endRefreshing()
        self.presentError(viewModel: viewModel)
    }
}
