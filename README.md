- [ ] 一度検知した後に、再検知する方法
    - サスペンド時はdidRangeBeaconは直接呼ばれないから、一度didExitRegion -> didEnterRegionの流れが必要？
    - didExitRegionがCallされるタイミング？